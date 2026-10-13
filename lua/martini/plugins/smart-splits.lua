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

-- (11/10/2026) Só mapeia a função que EXISTE na versão instalada do plugin.
-- Antes, vim.keymap.set recebia nil quando ss.move_cursor_previous não
-- existia (E5113: "rhs: expected string|function, got nil") e esse erro
-- abortava TODO o carregamento depois deste arquivo em plugins/init.lua
-- (oil, lualine, dashboard...). Agora a função ausente só gera um aviso.
local function map(lhs, fn_name, desc)
  local fn = ss[fn_name]
  if type(fn) ~= "function" then
    vim.notify("smart-splits: função ausente nesta versão: " .. fn_name, vim.log.levels.WARN)
    return
  end
  vim.keymap.set("n", lhs, fn, { desc = desc })
end

map("<M-h>", "move_cursor_left", "Navegar split/painel: esquerda (Neovim ↔ WezTerm)")
map("<M-j>", "move_cursor_down", "Navegar split/painel: baixo (Neovim ↔ WezTerm)")
map("<M-k>", "move_cursor_up", "Navegar split/painel: cima (Neovim ↔ WezTerm)")
map("<M-l>", "move_cursor_right", "Navegar split/painel: direita (Neovim ↔ WezTerm)")

-- (13/10/2026) move_cursor_previous FOI REMOVIDA do smart-splits na v2
-- ("could never work across a multiplexer boundary" — README, tabela
-- "Drop what no longer exists"). Por isso o aviso no dashboard. A tecla
-- Alt+\ continua existindo, mas agora usa o :wincmd p nativo do Neovim:
-- volta pro split anterior, SÓ dentro do Neovim (não cruza pro WezTerm).
vim.keymap.set("n", "<M-\\>", "<cmd>wincmd p<cr>", { desc = "Voltar pro split anterior (só dentro do Neovim)" })
