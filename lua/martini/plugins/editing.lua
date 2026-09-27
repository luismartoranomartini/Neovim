-- =========================================================
-- lua/martini/plugins/editing.lua
-- Pequenos plugins de conveniencia de edicao, agrupados por serem
-- coesos e pequenos individualmente: autopairs, autotag, surround, emmet.
--
-- SAFE_REQUIRE (09/09/2026): os pcall mudos foram trocados por
-- utils/safe_require.lua — se algum desses plugins nao estiver
-- instalado (ou o setup() falhar), voce recebe uma notificacao
-- dizendo qual plugin e o que fica sem funcionar, em vez de silencio
-- total (ver revisao do repositorio, item 2).
--
-- MINI.PAIRS / MINI.SURROUND (27/09/2026): nvim-autopairs e
-- nvim-surround saíram — ver nota "BLINK.CMP / MINI.PAIRS / MINI.
-- SURROUND / LUALINE" em lazy.lua pro motivo geral da troca.
-- =========================================================

local safe_require = require("martini.utils.safe_require")

-- Autopairs → mini.pairs: mesma familia do mini.ai/mini.icons ja em
-- uso. Nao tem (nem precisa) do hook de "depois de aceitar completion"
-- que o nvim-autopairs tinha (nvim-autopairs.completion.cmp) — mini.
-- pairs so reage a tecla digitada, nao a item de completion aceito,
-- entao nao ha risco de par duplicado ao aceitar sugestao do blink.cmp
-- (ver plugins/completion.lua).
safe_require("mini.pairs", function(mini_pairs)
  mini_pairs.setup({})
end, "fechar parenteses/aspas/colchetes automaticamente ao digitar")

-- Autotag — fecha/renomeia/atualiza tags HTML/JSX automaticamente
-- conforme digita, usando o Treesitter pra saber onde a tag termina.
safe_require("nvim-ts-autotag", function(nvim_ts_autotag)
  nvim_ts_autotag.setup()
end, "fechar/atualizar tags HTML/JSX automaticamente")

-- Surround → mini.surround: mesma familia do mini.ai ja em uso.
-- Mapeamentos remapeados pra preservar a convencao ys/cs/ds do antigo
-- nvim-surround (a ordem mapping+motion+alvo e a mesma nos dois):
--   ys{motion}{char} → adiciona (era "sa" por padrao no mini.surround)
--   cs{alvo}{novo}   → troca (era "sr")
--   ds{alvo}         → remove (era "sd")
-- find/find_left/highlight (sf/sF/sh por padrao) DESATIVADOS de
-- proposito: comecam com "s" sozinho, que colidiria com o "s"/"S" do
-- flash.nvim (navegacao por labels, plugins/flash.lua, fora da
-- gramatica <leader> de proposito) — o Neovim passaria a esperar o
-- timeoutlen inteiro toda vez que voce aperta "s" pra ver se vem
-- "f"/"F"/"h" depois, atrasando o flash. add/delete/replace nao tem
-- esse problema (comecam com y/d/c, nao com s sozinho).
-- ATENCAO: no modo Visual, quem embrulha a selecao agora e "ys{char}"
-- (mesma tecla do "add"), nao mais "S{char}" como no nvim-surround.
safe_require("mini.surround", function(mini_surround)
  mini_surround.setup({
    mappings = {
      add = "ys",
      delete = "ds",
      replace = "cs",
      find = "",
      find_left = "",
      highlight = "",
    },
  })
end, "atalhos ys/cs/ds pra adicionar, trocar ou remover delimitadores")

-- Emmet — abreviacoes de HTML/CSS/JSX expandidas via Tab (ver
-- plugins/completion.lua, integracao com blink.cmp).
vim.g.user_emmet_mode = "iv"
vim.g.user_emmet_install_global = 0

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html", "css", "scss", "jsx", "tsx" },
  callback = function() vim.cmd("EmmetInstall") end,
})
