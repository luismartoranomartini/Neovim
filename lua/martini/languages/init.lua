-- =========================================================
-- lua/martini/languages/init.lua
-- Regra desta pasta: tudo que é específico de UMA linguagem vive
-- aqui, não espalhado por plugins/. Hoje só Go.
-- IMPORTANTE: só REQUER o módulo (o require abaixo já roda os
-- vim.filetype.add()/autocmds do topo do arquivo). Funções como
-- setup_debug() e a tabela runner_filetypes são chamadas/lidas sob
-- demanda por plugins/debug.lua e plugins/runner.lua.
-- =========================================================

require("martini.languages.go")
require("martini.languages.c")
