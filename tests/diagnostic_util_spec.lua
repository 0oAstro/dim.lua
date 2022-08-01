describe("is_unused_symbol_diagnostic", function()
  local test_cases = {
    {
      description = "detects unused symbols from lua diagnostics",
      lsp_datum = {
        bufnr = 1,
        code = "unused-local",
        col = 53,
        end_col = 56,
        end_lnum = 124,
        lnum = 124,
        message = "Unused local `abc`.",
        namespace = 47,
        severity = 4,
        source = "Lua Diagnostics.",
        user_data = {
          lsp = {
            code = "unused-local",
            tags = { 1 },
          },
        },
      },
      expected_result = true,
    },
    {
      description = "detects unused symbols from tsserver diagnostics",
      lsp_datum = {
        bufnr = 41,
        code = 6133,
        col = 6,
        end_col = 20,
        end_lnum = 1,
        lnum = 1,
        message = "'someVariable' is declared but its value is never read.",
        namespace = 54,
        severity = 4,
        source = "typescript",
        user_data = {
          lsp = {
            code = 6133,
            tags = { 1 },
          },
        },
      },
      expected_result = true,
    },
    {
      description = "detects unused symbols from jdtls diagnostics",
      lsp_datum = {
        code = "536870973",
      },
      expected_result = true,
    },
    {
      description = "detects unused private methods from jdtls diagnostics",
      lsp_datum = {
        code = "603979894",
      },
      expected_result = true,
    },
  }

  local diagnostic_util = require("dim.diagnostic_util")

  for _, test_case in ipairs(test_cases) do
    it(test_case.description, function()
      local result = diagnostic_util.is_unused_symbol_diagnostic(test_case.lsp_datum)
      if test_case.expected_result then
        assert.truthy(result)
      else
        assert.falsy(result)
      end
    end)
  end
end)
