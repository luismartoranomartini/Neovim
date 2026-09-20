-- =========================================================
-- lua/martini/plugins/smart-splits.lua
-- Navegação contínua entre splits do Neovim e painéis do WezTerm
-- (smart-splits-nvim/smart-splits.nvim). Substitui o
-- vim-tmux-navigator: o tmux não é usado dentro do WezTerm.
--
-- Mesmas teclas de antes: Alt+h/j/k/l (NÃO Ctrl — Ctrl+j/k são
-- alias do multicursor, ver plugins/multicursor.lua).
--
-- O lado do WezTerm é configurado em ~/.config/wezterm/wezterm.lua.
-- Este plugin avisa ao WezTerm que o Neovim está rodando (variável
-- IS_NVIM); por isso precisa carregar no boot (lazy = false).
-- =========================================================

local ss = require("smart-splits")
local map = vim.keymap.set

map("n", "<M-h>", ss.move_cursor_left,  { desc = "Navegar split/painel: esquerda (Neovim ↔ WezTerm)" })
map("n", "<M-j>", ss.move_cursor_down,  { desc = "Navegar split/painel: baixo (Neovim ↔ WezTerm)" })
map("n", "<M-k>", ss.move_cursor_up,    { desc = "Navegar split/painel: cima (Neovim ↔ WezTerm)" })
map("n", "<M-l>", ss.move_cursor_right, { desc = "Navegar split/painel: direita (Neovim ↔ WezTerm)" })
map("n", "<M-\\>", ss.move_cursor_previous, { desc = "Navegar pro split/painel anterior" })
