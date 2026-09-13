-- =========================================================
-- lua/martini/plugins/treesitter.lua
-- Highlights específicos de Go (verbos de printf, ações de template)
-- ficam em languages/go.lua — aqui só o genérico.
-- Treesitter — API nova (branch "main" do nvim-treesitter). O módulo
-- "nvim-treesitter.configs" foi REMOVIDO na reescrita de 2024; não
-- existe mais ensure_installed/highlight.enable via configs.setup().
-- install() baixa e compila os parsers (idempotente), e o highlight
-- é ativado manualmente por buffer via vim.treesitter.start() no
-- autocmd FileType logo abaixo.
--
-- LISTA REDUZIDA (set/2026) ao que é realmente usado: Go, JS/TS/TSX
-- (web), C, HTML/CSS (templates Go + front-end), Lua (edição da
-- própria config), YAML (docker-compose, CI, configs). Removido:
-- python (fora do escopo atual).
-- =========================================================
local ts_langs = { "lua", "javascript", "typescript", "tsx", "go", "c", "html", "css", "yaml" }

pcall(function()
  require("nvim-treesitter").install(ts_langs)
end)

-- Força o início do Treesitter highlight ao abrir arquivos.
-- Necessário no 0.12 onde não existe mais highlight={enable=true}.
vim.api.nvim_create_autocmd("FileType", {
  pattern = ts_langs,
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
