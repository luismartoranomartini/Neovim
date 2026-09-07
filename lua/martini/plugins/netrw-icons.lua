-- =========================================================
-- lua/martini/plugins/netrw-icons.lua
-- Ícones no explorador nativo (:Lexplore / netrw).
--
-- NÃO substitui o netrw nem muda nenhuma tecla: mf/mt/mc/mm/mu,
-- <CR>, - continuam exatamente iguais. netrw.nvim só intercepta a
-- renderização do buffer do netrw pra desenhar um glyph por linha,
-- usando nvim-web-devicons como provedor de ícone/cor.
--
-- use_devicons = true: usa nvim-web-devicons pra escolher o ícone.
-- Se false, cairia nos ícones genéricos fixos em `icons` abaixo.
-- =========================================================
require("nvim-web-devicons").setup({
  default = true, -- ícone genérico de fallback quando a extensão é desconhecida
})

require("netrw").setup({
  use_devicons = true,
  icons = {
    symlink   = "",
    directory = "",
    file      = "",
  },
})
