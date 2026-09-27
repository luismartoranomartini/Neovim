-- =========================================================
-- lua/martini/plugins/mason.lua
-- Gerenciador de LSP servers, linters, formatadores e DAP adapters
-- (26/09/2026). SEM mason-lspconfig.nvim de propósito: lsp.lua usa a
-- API nativa (vim.lsp.config/vim.lsp.enable), não nvim-lspconfig — a
-- única coisa que o Mason precisa fazer aqui é colocar seus binários
-- no $PATH, o que ele já faz sozinho no setup(). configurar_lsp() em
-- lsp.lua usa vim.fn.exepath(), que enxerga esse PATH automaticamente.
--
-- ORDEM IMPORTA: este require precisa rodar ANTES de lsp.lua em
-- plugins/init.lua, senão o PATH ainda não está setado quando
-- configurar_lsp() roda os exepath().
-- =========================================================
require("martini.utils.safe_require")("mason", function(mason)
  mason.setup()
end, "gerenciador de LSP servers/linters/formatadores/DAP (mason.nvim)")
