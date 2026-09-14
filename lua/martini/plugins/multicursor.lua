-- =========================================================
-- lua/martini/plugins/multicursor.lua
-- Multiplos cursores (jake-stewart/multicursor.nvim, branch 1.0)
--
-- SAFE_REQUIRE (09/09/2026): já tinha tratamento de erro próprio
-- (pcall + vim.notify genérico) — trocado por utils/safe_require.lua
-- só pra ficar no mesmo padrão do resto da config (nome do plugin,
-- funcionalidade afetada e comando de correção na mensagem, em vez
-- de só o texto cru do erro). Ver nota completa em plugins/editing.lua.
-- =========================================================

local safe_require = require("martini.utils.safe_require")

safe_require("multicursor-nvim", function(mc)
  mc.setup()
  local map = vim.keymap.set
  -- Adiciona cursor na linha de cima/baixo (funciona em normal e visual)
  map({ "n", "x" }, "<C-Up>", function() mc.lineAddCursor(-1) end, { desc = "Multicursor: cursor acima" })
  map({ "n", "x" }, "<C-Down>", function() mc.lineAddCursor(1) end, { desc = "Multicursor: cursor abaixo" })
  -- Aliases <C-k>/<C-j> (09/09/2026), mesma ação de <C-Up>/<C-Down> —
  -- pedido explícito, com ressalva registrada: em alguns terminais,
  -- <C-j> é indistinguível de Enter (mesmo código de controle, \n),
  -- então pode não disparar de forma confiável dependendo do setup.
  -- <C-Up>/<C-Down> continuam sendo o caminho garantido.
  map({ "n", "x" }, "<C-k>", function() mc.lineAddCursor(-1) end, { desc = "Multicursor: cursor acima" })
  map({ "n", "x" }, "<C-j>", function() mc.lineAddCursor(1) end, { desc = "Multicursor: cursor abaixo" })
  -- Pula uma linha sem adicionar cursor (util pra saltar blocos)
  map({ "n", "x" }, "<leader>mj", function() mc.lineSkipCursor(1) end, { desc = "Multicursor: pular linha abaixo" })
  map({ "n", "x" }, "<leader>mk", function() mc.lineSkipCursor(-1) end, { desc = "Multicursor: pular linha acima" })
  -- Adiciona cursor na proxima/anterior ocorrencia da palavra sob o cursor
  -- (ou da selecao, em modo visual)
  map({ "n", "x" }, "<leader>mn", function() mc.matchAddCursor(1) end, { desc = "Multicursor: proxima ocorrencia" })
  map({ "n", "x" }, "<leader>mp", function() mc.matchAddCursor(-1) end, { desc = "Multicursor: ocorrencia anterior" })
  map({ "n", "x" }, "<leader>ms", function() mc.matchSkipCursor(1) end, { desc = "Multicursor: pular proxima ocorrencia" })
  -- "mp" já está ocupado por "ocorrência anterior" (add), então "pular
  -- a anterior" (skip) precisa de combinação própria: msp = ms + p.
  map({ "n", "x" }, "<leader>msp", function() mc.matchSkipCursor(-1) end, { desc = "Multicursor: pular ocorrencia anterior" })
  -- Adiciona cursor em TODAS as ocorrencias do documento de uma vez
  map({ "n", "x" }, "<leader>ma", mc.matchAllAddCursors, { desc = "Multicursor: selecionar todas ocorrencias" })
  -- Alterna qual cursor e o "principal" (util pra revisar edicoes)
  map({ "n", "x" }, "<leader>mh", mc.prevCursor, { desc = "Multicursor: cursor principal anterior" })
  map({ "n", "x" }, "<leader>ml", mc.nextCursor, { desc = "Multicursor: proximo cursor principal" })
  -- Remove o cursor principal atual
  map({ "n", "x" }, "<leader>mx", mc.deleteCursor, { desc = "Multicursor: remover cursor" })
  -- Ativa/desativa os cursores extras sem apaga-los
  map({ "n", "x" }, "<leader>mq", mc.toggleCursor, { desc = "Multicursor: ativar/desativar cursores" })
  -- Camada de atalhos que so vale enquanto ha multiplos cursores ativos.
  -- <Esc> aqui fecha o modo multicursor (ou desativa, se ja estiver desativado).
  mc.addKeymapLayer(function(layerSet)
    layerSet({ "n", "x" }, "<Esc>", function()
      if not mc.cursorsEnabled() then
        mc.enableCursors()
      else
        mc.clearCursors()
      end
    end)
    layerSet({ "n", "x" }, "<leader>mh", mc.prevCursor)
    layerSet({ "n", "x" }, "<leader>ml", mc.nextCursor)
    layerSet({ "n", "x" }, "<leader>mx", mc.deleteCursor)
  end)
  -- Aparencia dos cursores extras — combina com o tema tokyonight
  -- definido em colors.lua
  local hl = vim.api.nvim_set_hl
  -- Fundo SÓLIDO em vez de link pra outros grupos (Visual/Search) —
  -- link depende do que tokyonight/colors.lua define pra esses
  -- grupos, e contra o fundo preto puro (config/colors.lua) o
  -- contraste ficava baixo demais pra notar a seleção/preview.
  hl(0, "MultiCursorCursor", { reverse = true })
  hl(0, "MultiCursorVisual", { bg = "#bd93f9", fg = "#000000" })
  hl(0, "MultiCursorSign", { bg = "#bd93f9" })
  hl(0, "MultiCursorMatchPreview", { bg = "#ffd700", fg = "#000000" })
  hl(0, "MultiCursorDisabledCursor", { reverse = true })
  hl(0, "MultiCursorDisabledVisual", { bg = "#7a8290", fg = "#000000" })
  hl(0, "MultiCursorDisabledSign", { bg = "#7a8290" })
end, "múltiplos cursores (<leader>m*, <C-Up>/<C-Down>)")
