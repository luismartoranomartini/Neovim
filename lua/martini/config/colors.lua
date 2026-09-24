-- =========================================================
-- lua/martini/config/colors.lua
-- Teste: tokyonight customizado (fundo azul-marinho), inspirado no
-- setup do josean-dev/dev-environment-files
--
-- MUDANÇA DE ABORDAGEM (24/09/2026): as versões anteriores desta
-- paleta (terrosa, depois roxo-ardósia) definiam manualmente TODOS os
-- grupos de sintaxe (@function, @keyword, @string, etc.) por cima do
-- tokyonight base. Essa versão faz diferente: usa on_colors() do
-- próprio tokyonight.nvim pra só trocar fundo/frente/realces, e deixa
-- o plugin decidir as cores de sintaxe sozinho (é o que ele já faz
-- bem — replicar isso manualmente era trabalho redundante). Só
-- mantemos highlight manual pro que o tokyonight NÃO conhece: nossos
-- grupos próprios (MartiniTabLine*, OilGitStatus*, FzfLua*) e sinais
-- de DAP — usando as cores oficiais da paleta tokyonight-night, pra
-- ficar visualmente consistente com o resto.
--
-- CIANO VOLTA DE PROPÓSITO: essa é a mudança mais significativa em
-- relação às versões anteriores — o tokyonight usa ciano pra
-- namespaces/propriedades por padrão. Confirmado explicitamente antes
-- de aplicar (ver conversa).
-- =========================================================

-- Cores oficiais tokyonight-night (confirmadas em tokyonight.org/palette
-- e no repo folke/tokyonight.nvim) — usadas nos grupos manuais abaixo
local tn = {
  bg_dark  = "#011423", -- override de Josean (era #16161e no tokyonight puro)
  bg       = "#011628", -- override de Josean (era #1a1b26 no tokyonight puro)
  bg_hl    = "#143652", -- override de Josean (era #292e42 no tokyonight puro)
  fg       = "#CBE0F0", -- override de Josean (era #c0caf5 no tokyonight puro)
  comment  = "#565f89",
  red      = "#f7768e",
  orange   = "#ff9e64",
  yellow   = "#e0af68",
  green    = "#9ece6a",
  cyan     = "#7dcfff",
  blue     = "#7aa2f7",
  magenta  = "#bb9af7",
  purple   = "#9d7cd8",
}

local function aplicar_highlights()
  local hl = vim.api.nvim_set_hl

  -- Verbos de formatação estilo printf (Go, C — ver
  -- utils/printf_highlight.lua) → AMARELO, mesma cor de tipos.
  hl(0, "PrintfVerb", { fg = tn.yellow })

  -- Ações de template Go ({{ }}) em .html/.tmpl → MAGENTA.
  hl(0, "GoTemplateAction", { fg = tn.magenta, bold = true })

  -- nvim-dap: cores dos signs de breakpoint (ver plugins/debug.lua e
  -- languages/go.lua).
  hl(0, "DapBreakpointHl", { fg = tn.red })
  hl(0, "DapBreakpointConditionHl", { fg = tn.orange })
  hl(0, "DapLogPointHl", { fg = tn.blue })
  hl(0, "DapStoppedHl", { fg = tn.green })
  hl(0, "DapBreakpointRejectedHl", { fg = tn.comment })
  hl(0, "DapStoppedLine", { bg = tn.bg_hl })

  -- Indicador de arquivo não salvo na statusline (ver config/options.lua)
  hl(0, "StatusLineModified", { fg = "#000000", bg = tn.orange, bold = true })

  -- Sinais de git no gutter (ver plugins/gitsigns.lua)
  hl(0, "GitSignsAdd", { fg = tn.green })
  hl(0, "GitSignsChange", { fg = tn.orange })
  hl(0, "GitSignsDelete", { fg = tn.red })
  hl(0, "GitSignsTopdelete", { fg = tn.red })
  hl(0, "GitSignsChangedelete", { fg = tn.orange })
  hl(0, "GitSignsUntracked", { fg = tn.comment })

  -- Status de git na listagem do oil (ver plugins/oil.lua) — working
  -- tree em tom cheio, índice (staged) em itálico pra diferenciar.
  hl(0, "OilGitStatusWorkingTreeModified", { fg = tn.orange })
  hl(0, "OilGitStatusWorkingTreeAdded", { fg = tn.green })
  hl(0, "OilGitStatusWorkingTreeDeleted", { fg = tn.red })
  hl(0, "OilGitStatusWorkingTreeUntracked", { fg = tn.cyan })
  hl(0, "OilGitStatusWorkingTreeRenamed", { fg = tn.purple })
  hl(0, "OilGitStatusWorkingTreeCopied", { fg = tn.purple })
  hl(0, "OilGitStatusWorkingTreeTypeChanged", { fg = tn.orange })
  hl(0, "OilGitStatusWorkingTreeUnmerged", { fg = tn.red, bold = true })
  hl(0, "OilGitStatusWorkingTreeIgnored", { fg = tn.comment })
  hl(0, "OilGitStatusWorkingTreeUnmodified", { fg = tn.comment })
  hl(0, "OilGitStatusIndexModified", { fg = tn.orange, italic = true })
  hl(0, "OilGitStatusIndexAdded", { fg = tn.green, italic = true })
  hl(0, "OilGitStatusIndexDeleted", { fg = tn.red, italic = true })
  hl(0, "OilGitStatusIndexUntracked", { fg = tn.cyan, italic = true })
  hl(0, "OilGitStatusIndexRenamed", { fg = tn.purple, italic = true })
  hl(0, "OilGitStatusIndexCopied", { fg = tn.purple, italic = true })
  hl(0, "OilGitStatusIndexTypeChanged", { fg = tn.orange, italic = true })
  hl(0, "OilGitStatusIndexUnmerged", { fg = tn.red, bold = true, italic = true })
  hl(0, "OilGitStatusIndexIgnored", { fg = tn.comment, italic = true })
  hl(0, "OilGitStatusIndexUnmodified", { fg = tn.comment, italic = true })

  -- Tabline de buffers (ver config/tabline.lua)
  hl(0, "MartiniTabLineSel", { fg = tn.fg, bg = tn.bg_hl, bold = true })
  hl(0, "MartiniTabLine", { fg = tn.comment, bg = tn.bg_dark })
  hl(0, "MartiniTabLineFill", { bg = tn.bg_dark })
  hl(0, "MartiniTabLineGit", { fg = tn.orange, bold = true })

  -- fzf-lua (ver plugins/finder.lua)
  hl(0, "FzfLuaNormal", { bg = tn.bg_dark })
  hl(0, "FzfLuaBorder", { fg = tn.comment, bg = tn.bg_dark })
  hl(0, "FzfLuaTitle", { fg = tn.blue, bold = true })
  hl(0, "FzfLuaFzfNormal", { bg = tn.bg_dark })
  hl(0, "FzfLuaFzfBorder", { fg = tn.comment, bg = tn.bg_dark })
  hl(0, "FzfLuaFzfPrompt", { fg = tn.blue, bold = true })
  hl(0, "FzfLuaFzfQuery", { fg = tn.fg })
  hl(0, "FzfLuaFzfMatch", { fg = tn.orange, bold = true })
  hl(0, "FzfLuaFzfPointer", { fg = tn.green })
  hl(0, "FzfLuaFzfMarker", { fg = tn.magenta })
  hl(0, "FzfLuaFzfCursorLine", { bg = tn.bg_hl })
  hl(0, "FzfLuaCursorLine", { bg = tn.bg_hl })
  hl(0, "FzfLuaPreviewNormal", { bg = tn.bg_dark })
  hl(0, "FzfLuaPreviewBorder", { fg = tn.cyan, bg = tn.bg_dark })
  hl(0, "FzfLuaPreviewTitle", { fg = tn.cyan, bold = true })
  hl(0, "FzfLuaHeaderText", { fg = tn.comment })
  hl(0, "FzfLuaHeaderBind", { fg = tn.comment })
end

-- SAFE_REQUIRE: pcall mudo trocado por utils/safe_require.lua — ver
-- nota completa em plugins/editing.lua.
require("martini.utils.safe_require")("tokyonight", function(tokyonight)
  local transparent = false

  tokyonight.setup({
    style = "night",
    transparent = transparent,
    styles = {
      comments = { italic = true },
      keywords = { bold = false },
      functions = { bold = false },
      sidebars = transparent and "transparent" or "dark",
      floats = transparent and "transparent" or "dark",
    },
    -- Override de fundo/frente pro tom azul-marinho de Josean, em vez
    -- do preto/cinza-azulado padrão do tokyonight-night. Isso é o que
    -- muda a "cara" do tema sem redefinir cada grupo de sintaxe à mão
    -- — o tokyonight recalcula os grupos derivados sozinho.
    on_colors = function(colors)
      colors.bg = tn.bg
      colors.bg_dark = transparent and colors.none or tn.bg_dark
      colors.bg_float = transparent and colors.none or tn.bg_dark
      colors.bg_highlight = tn.bg_hl
      colors.bg_popup = tn.bg_dark
      colors.bg_search = "#0A64AC"
      colors.bg_sidebar = transparent and colors.none or tn.bg_dark
      colors.bg_statusline = transparent and colors.none or tn.bg_dark
      colors.bg_visual = "#275378"
      colors.border = "#547998"
      colors.fg = tn.fg
      colors.fg_dark = "#B4D0E9"
      colors.fg_float = tn.fg
      colors.fg_gutter = "#627E97"
      colors.fg_sidebar = "#B4D0E9"
    end,
  })

  vim.cmd.colorscheme("tokyonight-night")
end, "tema de cores base (tokyonight-night, override de Josean)")

aplicar_highlights()

vim.api.nvim_create_autocmd("ColorScheme", { callback = aplicar_highlights })
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function() vim.defer_fn(aplicar_highlights, 300) end,
})
