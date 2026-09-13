-- =========================================================
-- lua/martini/plugins/format.lua
-- Formatação automática via conform.nvim (genérico, multi-linguagem).
-- O linting de Go (golangci-lint) e a organização automática de
-- imports do Go foram para languages/go.lua — comportamento
-- específico de uma linguagem, não deste plugin. O formato do
-- próprio Go (gofmt) já vem do lsp_format = "fallback" abaixo, via
-- gopls — não precisa de formatador dedicado aqui.
--
-- SAFE_REQUIRE (09/09/2026): pcall mudo trocado por
-- utils/safe_require.lua — ver nota completa em plugins/editing.lua.
-- =========================================================

local safe_require = require("martini.utils.safe_require")

safe_require("conform", function(conform)
  conform.setup({
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      c = { "clang-format" },
      cpp = { "clang-format" },
    },
    format_on_save = {
      timeout_ms = 1000,
      lsp_format = "fallback",
    },
  })
end, "formatação automática ao salvar (format on save)")
