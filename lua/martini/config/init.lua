-- =========================================================
-- lua/martini/config/init.lua
-- Regra desta pasta: "config/ configura o Neovim, não plugins."
--
-- NETRW → OIL (09/09/2026): require("martini.config.netrw") REMOVIDO
-- (arquivo config/netrw.lua excluído junto). netrw saiu de cena por
-- completo — quem assume qualquer diretório aberto agora é
-- stevearc/oil.nvim, configurado em plugins/oil.lua (pasta plugins/,
-- não config/, por ser configuração de PLUGIN, não do Neovim em si).
--
-- TABLINE DE BUFFERS (09/09/2026): require("martini.config.tabline")
-- ADICIONADO — tabline nativa customizada, sem plugin, listando
-- buffers abertos em vez de tabpages. Ver notas completas dentro de
-- config/tabline.lua, incluindo a tensão com <leader>n/<leader>w.
-- =========================================================
require("martini.config.options")
require("martini.config.diagnostics")
require("martini.config.colors")
require("martini.config.tabline")
require("martini.config.keymaps")
