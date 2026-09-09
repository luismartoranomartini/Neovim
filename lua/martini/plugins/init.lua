-- =========================================================
-- lua/martini/plugins/init.lua
-- Regra desta pasta: "plugins/ configura plugins, não o Neovim."
-- Cada arquivo aqui é responsável por UM plugin (ou um grupo bem
-- pequeno e coeso, como completion = cmp+luasnip).
--
-- CORREÇÃO (07/09/2026): faltavam DOIS requires nesta lista —
-- descoberto ao rastrear o grafo de require() de ponta a ponta:
--
-- 1. require("martini.languages") — languages/init.lua faz
--    require("martini.languages.go") + require("martini.languages.c"),
--    mas nada chamava require("martini.languages") em lugar nenhum.
--    go.lua funcionava por acidente (runner.lua e debug.lua já
--    fazem require("martini.languages.go") direto, pra ler
--    M.runner_filetypes/M.setup_debug, o que já disparava o código
--    de topo do arquivo). c.lua não tinha NENHUM outro require
--    apontando pra ele — o highlight de printf/scanf do C nunca
--    rodava. Precisa vir ANTES dos plugins que dependem de go.lua
--    (runner, debug), embora Lua cacheie o módulo e a ordem exata
--    entre eles não quebre nada se invertida.
--
-- 2. require("martini.plugins.otter") — o arquivo existia, o plugin
--    jmbuhr/otter.nvim está em lazy.lua e é baixado normalmente, mas
--    o setup() e o autocmd de ativação nunca eram chamados. Sem essa
--    linha, autocomplete de JS/CSS dentro de <script>/<style> em
--    HTML simplesmente não existe, apesar do plugin estar instalado.
--    Colocado DEPOIS de completion+lsp: otter.activate() precisa
--    que ts_ls/cssls já estejam configurados em vim.lsp.config.
--
-- NETRW → OIL (09/09/2026): require("martini.plugins.netrw-icons")
-- REMOVIDO (arquivo excluído junto). No lugar,
-- require("martini.plugins.oil") — netrw sai de cena por completo
-- (ver notas em lazy.lua e plugins/oil.lua). Mantido na mesma posição
-- da lista (afinidade temática: navegação/arquivos), sem dependência
-- de LSP ou completion, então a posição exata não importa.
-- =========================================================
require("martini.languages") -- go.lua + c.lua — ver nota acima
require("martini.plugins.treesitter")
require("martini.plugins.textobjects") -- depende dos parsers registrados acima
require("martini.plugins.editing")
require("martini.plugins.completion")
require("martini.plugins.lsp")
require("martini.plugins.otter") -- precisa vir depois de completion+lsp
require("martini.plugins.format")
require("martini.plugins.debug")
require("martini.plugins.runner")
require("martini.plugins.http")
require("martini.plugins.multicursor")
require("martini.plugins.finder")
require("martini.plugins.oil") -- ver nota "NETRW → OIL" acima
require("martini.plugins.dashboard")
