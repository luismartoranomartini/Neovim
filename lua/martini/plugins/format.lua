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
      -- (01/10/2026) lua → stylua (pacman -S stylua); go → gofmt (vem com
      -- o toolchain Go); json → prettier. Go antes caía no fallback do
      -- LSP (gopls), que continua valendo se o gofmt não estiver no PATH.
      lua = { "stylua" },
      go = { "gofmt" },
      json = { "prettier" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      python = { "ruff_organize_imports", "ruff_format" },
      c = { "clang-format" },
      cpp = { "clang-format" },
    },
    format_on_save = {
      timeout_ms = 1000,
      lsp_format = "fallback",
    },
  })
end, "formatação automática ao salvar (format on save)")
