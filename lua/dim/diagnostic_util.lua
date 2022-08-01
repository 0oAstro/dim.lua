local matchers = require("dim.matchers")

local M = {}

---@param lsp_datum Diagnostic
local function get_message_from_lsp_diagnostic(lsp_datum)
  if lsp_datum.code and type(lsp_datum.code) == "string" then
    return lsp_datum.code
  end

  return lsp_datum.message or ""
end

function M.is_unused_symbol_diagnostic(lsp_datum)
  local message = string.lower(get_message_from_lsp_diagnostic(lsp_datum))
  for _, matcher in ipairs(matchers) do
    if string.match(message, matcher) then
      return true
    end
  end
  return false
end

return M
