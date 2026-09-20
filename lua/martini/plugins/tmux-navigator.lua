-- =========================================================
-- lua/martini/plugins/tmux-navigator.lua
-- Navegação contínua entre splits do Neovim e painéis do tmux
-- (christoomey/vim-tmux-navigator) — mesma tecla funciona pros dois,
-- sem precisar pensar "estou dentro ou fora do Neovim agora".
--
-- ALT (M-), NÃO Ctrl (09/09/2026): o padrão do plugin é
-- Ctrl+h/j/k/l, mas essas 4 já são alias do multicursor
-- (<C-j>/<C-k> = cursor acima/abaixo, ver plugins/multicursor.lua) —
-- decisão explícita de manter o multicursor como está e usar Alt
-- aqui, em vez de sacrificar o alias. g:tmux_navigator_no_mappings
-- desliga o mapeamento automático do próprio plugin antes de
-- registrar o nosso.
--
-- IMPORTANTE — só funciona de dentro do Neovim sem configuração
-- extra. Pra funcionar nos DOIS sentidos (sair do Neovim pra um
-- painel do tmux, E entrar de volta), o lado do tmux precisa da
-- mesma tecla configurada em ~/.tmux.conf — fora do escopo deste
-- repositório (arquivo do sistema, não do Neovim). Sem isso, Alt+h/
-- j/k/l só navega splits DENTRO do Neovim, não atravessa pro tmux.
-- =========================================================

vim.g.tmux_navigator_no_mappings = 1

local map = vim.keymap.set

map("n", "<M-h>", "<CMD><C-U>TmuxNavigateLeft<CR>", { desc = "Navegar split/painel: esquerda (Neovim ↔ tmux)" })
map("n", "<M-j>", "<CMD><C-U>TmuxNavigateDown<CR>", { desc = "Navegar split/painel: baixo (Neovim ↔ tmux)" })
map("n", "<M-k>", "<CMD><C-U>TmuxNavigateUp<CR>", { desc = "Navegar split/painel: cima (Neovim ↔ tmux)" })
map("n", "<M-l>", "<CMD><C-U>TmuxNavigateRight<CR>", { desc = "Navegar split/painel: direita (Neovim ↔ tmux)" })
map("n", "<M-\\>", "<CMD><C-U>TmuxNavigatePrevious<CR>", { desc = "Navegar pro split/painel anterior (Neovim ↔ tmux)" })
