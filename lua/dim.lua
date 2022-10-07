local dim = {}
local util = {}

local highlighter = require("vim.treesitter.highlighter")
local ts_utils = require("nvim-treesitter.ts_utils")

------------------------
--## UTIL FUNCTIONS ##--
------------------------
---@param hex_str string hexadecimal value of a color
function util.hex_to_rgb(hex_str)
  local hex = "[abcdef0-9][abcdef0-9]"
  local pat = "^#(" .. hex .. ")(" .. hex .. ")(" .. hex .. ")$"
  hex_str = string.lower(hex_str)

  assert(string.find(hex_str, pat) ~= nil, "hex_to_rgb: invalid hex_str: " .. tostring(hex_str))

  local red, green, blue = string.match(hex_str, pat)
  return { tonumber(red, 16), tonumber(green, 16), tonumber(blue, 16) }
end

---@param fg string foreground color
---@param bg string background color
---@param alpha number number between 0 and 1. 0 results in bg, 1 results in fg
function util.blend(fg, bg, alpha)
  bg = util.hex_to_rgb(bg)
  fg = util.hex_to_rgb(fg)

  local blendChannel = function(i)
    local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
    return math.floor(math.min(math.max(0, ret), 255) + 0.5)
  end

  return string.format("#%02X%02X%02X", blendChannel(1), blendChannel(2), blendChannel(3))
end

function util.darken(hex, amount, bg)
  return util.blend(hex, bg or "#000000", math.abs(amount))
end

function util.highlight_word(line, from, to)
  -- null ls
  if from == to and to == 0 then
    from = 0
    to = 120
  end
  local ts_hi = util.get_treesitter_hl(line, from)
  local final = #ts_hi >= 1 and ts_hi[#ts_hi]
  if type(final) ~= "string" then
    final = "Normal"
  end
  local hl = vim.api.nvim_get_hl_by_name(final, true)
  local color = string.format("#%x", hl["foreground"] or 0)
  if #color ~= 7 then
    color = "#ffffff"
  end
  local hl_group = string.format("%sDimmed", final)
  vim.api.nvim_set_hl(0, hl_group, { fg = util.darken(color, 0.75), undercurl = false, underline = false })
  vim.api.nvim_buf_add_highlight(0, dim.ns, hl_group, line, from, to)
  if dim.opts.disable_lsp_decorations then
    for _, lsp_ns in pairs(vim.diagnostic.get_namespaces()) do
      local namespaces_to_clear = { "underline_ns", "virt_text_ns", "sign_group" }
      for _, ns_to_clear in ipairs(namespaces_to_clear) do
        if lsp_ns.user_data[ns_to_clear] then
          local id = lsp_ns.user_data[ns_to_clear]
          if type(id) == "string" then
            vim.fn.sign_unplace(id, { buffer = vim.api.nvim_get_current_buf() })
          else
            vim.api.nvim_buf_clear_namespace(0, id, line, line + 1)
          end
        end
      end
    end
  end
end

function util.get_treesitter_hl(row, col)
  local buf = vim.api.nvim_get_current_buf()

  -- NOTE: use new functionality from https://github.com/neovim/neovim/issues/14090#issuecomment-1228444035
  if vim.treesitter.get_captures_at_pos ~= nil then
    local matches = vim.treesitter.get_captures_at_pos(buf, row, col)
    return vim.tbl_map(function(match)
      return "@" .. match.capture
    end, matches)
  end

  local self = highlighter.active[buf]
  if not self then
    return {}
  end

  local matches = {}

  self.tree:for_each_tree(function(tstree, tree)
    if not tstree then
      return
    end

    local root = tstree:root()
    local root_start_row, _, root_end_row, _ = root:range()

    if root_start_row > row or root_end_row < row then
      return
    end

    local query = self:get_query(tree:lang())

    if not query:query() then
      return
    end

    local iter = query:query():iter_captures(root, self.bufnr, row, row + 1)

    for capture, node, _ in iter do
      local hl = query.hl_cache[capture]

      if hl and ts_utils.is_in_node_range(node, row, col) then
        local c = query._query.captures[capture] -- name of the capture in the query
        if c ~= nil then
          local general_hl = query:_get_hl_from_capture(capture)
          table.insert(matches, general_hl)
        end
      end
    end
  end, true)
  return matches
end

local diagnostic_util = require("dim.diagnostic_util")

-- UTIL FUNCTIONS END
--- Highlight unused vars and functions
dim.hig_unused = function()
  local ok, lsp_data = pcall(vim.diagnostic.get, 0)
  if ok then
    vim.api.nvim_buf_clear_namespace(0, dim.ns, 0, -1)
    for _, lsp_datum in ipairs(lsp_data) do
      if diagnostic_util.is_unused_symbol_diagnostic(lsp_datum) then
        util.highlight_word(lsp_datum.lnum, lsp_datum.col, lsp_datum.end_col)
      end
    end
  end
end

dim.opts = { disable_lsp_decorations = false }

--- Setup Function
--- @param tbl table config options
dim.setup = function(tbl)
  dim.opts = vim.tbl_deep_extend("force", dim.opts, tbl or {})
  dim.ns = vim.api.nvim_create_namespace("Dim")

  dim.hig_unused()

  vim.cmd([[
    augroup dim
    autocmd!
    autocmd DiagnosticChanged * lua require("dim").hig_unused()
    augroup END
  ]])
end

return dim
