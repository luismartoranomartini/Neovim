-- =========================================================
-- lua/martini/plugins/editing.lua
-- Pequenos plugins de conveniência de edição, agrupados por serem
-- coesos e pequenos individualmente: autopairs, autotag, surround, emmet.
--
-- SAFE_REQUIRE (09/09/2026): os 3 pcall mudos foram trocados por
-- utils/safe_require.lua — se algum desses plugins não estiver
-- instalado (ou o setup() falhar), você recebe uma notificação
-- dizendo qual plugin e o que fica sem funcionar, em vez de silêncio
-- total (ver revisão do repositório, item 2).
-- =========================================================

local safe_require = require("martini.utils.safe_require")

-- Autopairs
safe_require("nvim-autopairs", function(nvim_autopairs)
  nvim_autopairs.setup({ check_ts = true })
end, "fechar parênteses/aspas/colchetes automaticamente ao digitar")

-- Autotag — fecha/renomeia/atualiza tags HTML/JSX automaticamente
-- conforme digita, usando o Treesitter pra saber onde a tag termina.
safe_require("nvim-ts-autotag", function(nvim_ts_autotag)
  nvim_ts_autotag.setup()
end, "fechar/atualizar tags HTML/JSX automaticamente")

-- Surround — seleciona/adiciona/troca delimitadores ("", '', (), [], {}, <>)
-- ao redor de palavra ou seleção visual, no estilo VSCode "Select + wrap".
-- Keymaps padrão do plugin (não usa <leader>):
--   ys{motion}{char} → adiciona delimitador (ex.: ysiw" envolve a palavra em "")
--   cs{alvo}{novo}   → troca delimitador (ex.: cs"' troca " por ')
--   ds{alvo}         → remove delimitador (ex.: ds" remove as aspas)
--   Visual + S{char} → envolve a seleção visual no delimitador escolhido
safe_require("nvim-surround", function(nvim_surround)
  nvim_surround.setup({})
end, "atalhos ys/cs/ds pra adicionar, trocar ou remover delimitadores")

-- Emmet — abreviações de HTML/CSS/JSX expandidas via Tab (ver
-- plugins/completion.lua, integração com nvim-cmp).
vim.g.user_emmet_mode = "iv"
vim.g.user_emmet_install_global = 0

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html", "css", "scss", "jsx", "tsx" },
  callback = function() vim.cmd("EmmetInstall") end,
})
