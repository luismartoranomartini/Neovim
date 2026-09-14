-- =========================================================
-- lua/martini/plugins/gitsigns.lua
-- Sinais de git no gutter (coluna à esquerda do número da linha) —
-- mostra quais linhas foram adicionadas/modificadas/removidas desde
-- o último commit, dentro do próprio arquivo aberto.
--
-- Complementa (não substitui) o oil-git-status.nvim, configurado
-- dentro de plugins/oil.lua: gitsigns mostra POR LINHA, dentro do
-- arquivo; oil-git-status mostra POR ARQUIVO, na listagem do
-- explorador. Cores dos dois ficam centralizadas em config/colors.lua.
--
-- vim.b[bufnr].gitsigns_status_dict também é consumido por
-- config/tabline.lua, pra marcar na aba do buffer se o arquivo tem
-- mudança não commitada — não precisa reimplementar a checagem de
-- git lá, só ler o que o gitsigns já calculou.
-- =========================================================

local safe_require = require("martini.utils.safe_require")

safe_require("gitsigns", function(gitsigns)
  gitsigns.setup({
    signs = {
      add          = { text = "│" },
      change       = { text = "│" },
      delete       = { text = "▁" },
      topdelete    = { text = "▔" },
      changedelete = { text = "~" },
      untracked    = { text = "┆" },
    },
    -- current_line_blame fica desligado de propósito — texto flutuante
    -- de "quem mudou essa linha" toda hora é ruído; consulta sob
    -- demanda continua disponível via require("gitsigns").blame_line()
    -- se um dia você quiser um atalho pra isso.
    current_line_blame = false,
  })
end, "sinais de git no gutter (linhas adicionadas/modificadas/removidas)")
