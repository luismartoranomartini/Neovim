-- =========================================================
-- lua/martini/config/init.lua
-- Agregador de config/ — "config/ configura o Neovim, não plugins."
-- Ordem importa: options primeiro (mapleader precisa existir antes de
-- qualquer vim.keymap.set em keymaps.lua/doc_keymaps.lua), diagnostics
-- e colors na sequência (colors.lua lê valores de diagnostics pra
-- combinar cores), tabline depois de colors (usa a paleta "cor"),
-- doc_keymaps antes de keymaps (documentação/comandos de ajuda antes
-- dos mapeamentos em si).
--
-- CORREÇÃO (27/09/2026): este arquivo estava com o conteúdo ERRADO —
-- uma cópia de plugins/init.lua colada aqui por engano, sem nenhum
-- require de config/*.lua. Resultado: require("martini.config") em
-- martini/init.lua rodava sem erro (os requires de plugins/* que
-- tinham ficado aqui são válidos, só redundantes com plugins/init.lua,
-- e Lua cacheia — não duplicava efeito), mas vim.g.mapleader nunca era
-- setado (options.lua nunca rodava), então TODOS os <leader> ficavam
-- mortos, silenciosamente, sem nenhum erro no boot.
-- =========================================================
require("martini.config.options")
require("martini.config.diagnostics")
require("martini.config.colors")
require("martini.config.tabline")
require("martini.config.doc_keymaps")
require("martini.config.keymaps")
