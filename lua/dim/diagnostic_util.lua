local M = {}

local function get_message_from_lsp_diagnostic(lsp_datum)
  return (lsp_datum.user_data and lsp_datum.user_data.lsp.code) or lsp_datum.message or ""
end

function M.is_unused_symbol_diagnostic(lsp_datum)
  local message = string.lower(get_message_from_lsp_diagnostic(lsp_datum))
  return string.match(message, "never read") or string.match(message, "unused")
end

return M
