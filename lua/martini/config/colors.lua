-- =========================================================
-- lua/martini/config/colors.lua
-- Tema base: tokyonight customizado, fundo roxo saturado.
--
-- MUDANÇA DE ABORDAGEM (24/09/2026): as versões anteriores desta
-- paleta (terrosa, depois roxo-ardósia, depois azul-marinho estilo
-- josean-dev) definiam manualmente TODOS os grupos de sintaxe
-- (@function, @keyword, @string, etc.) por cima do tokyonight base.
-- Essa versão faz diferente: usa on_colors() do próprio
-- tokyonight.nvim pra só trocar fundo/frente/realces, e deixa o
-- plugin decidir as cores de sintaxe sozinho (é o que ele já faz bem
-- — replicar isso manualmente era trabalho redundante). Só mantemos
-- highlight manual pro que o tokyonight NÃO conhece: nossos grupos
-- próprios (MartiniTabLine*, OilGitStatus*, FzfLua*) e sinais de DAP
-- — usando as cores oficiais da paleta tokyonight-night, pra ficar
-- visualmente consistente com o resto.
--
-- BUG DE TRANSPARÊNCIA (25/09/2026): `colors.bg` estava fixo,
-- sem checar `transparent` — diferente de bg_dark/bg_float/
-- bg_sidebar/bg_statusline, que já viravam `colors.none`
-- corretamente. Resultado: com `transparent = true`, TUDO ficava
-- transparente MENOS o fundo principal (`Normal`), que continuava
-- sólido e cobria a opacidade do WezTerm por cima do texto.
-- Corrigido abaixo.
--
-- FUNDO ROXO (26/09/2026): trocado o fundo azul-marinho (estilo
-- josean-dev) por roxo. Primeira tentativa (`#211e26`) ficou
-- amarronzada por falta de saturação — corrigido para um roxo mais
-- saturado (`#2e2440`, opção "B" testada visualmente contra `#211e26`
-- e `#2a2438`). bg_dark e bg_hl escalados proporcionalmente na mesma
-- família de cor (mais escuro/mais claro que o bg principal).
--
-- CONTRASTE DE TAGS CSS/HTML (26/09/2026): seletores de elemento
-- (`header`, `div`, `<html>`, etc.) caindo no grupo padrão do
-- tokyonight pra @tag, que usa um tom apagado (próximo de
-- tn.comment) — quase invisível contra o fundo roxo saturado.
-- Forçado abaixo pra tn.blue, com bom contraste de matiz e
-- luminância contra o fundo.
-- =========================================================

-- Cores oficiais tokyonight-night (confirmadas em tokyonight.org/palette
-- e no repo folke/tokyonight.nvim) — usadas nos grupos manuais abaixo
local tn = {
  bg_dark  = "#211934", -- roxo saturado, variante mais escura (sidebars/statusline/tabline)
  bg       = "#2e2440", -- roxo saturado (fundo principal) — opção "B"
  bg_hl    = "#453465", -- roxo saturado, variante mais clara (CursorLine, buffer ativo)
  fg       = "#F5FAFF",
  comment  = "#565f89",
  red      = "#f7768e",
  orange   = "#ff9e64",
  yellow   = "#e0af68",
  green    = "#9ece6a",
  cyan     = "#7dcfff",
  blue     = "#7aa2f7",
  magenta  = "#d0b3ff",
  purple   = "#b8a0f0",
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

  -- Tags/seletores de elemento em CSS/HTML/JSX (26/09/2026) — ver nota
  -- "CONTRASTE DE TAGS CSS/HTML" no topo do arquivo. Cobre tanto os
  -- captures de treesitter (@tag*) quanto os grupos legados de vim
  -- regex (cssTagName/htmlTagName), porque dependendo do filetype um
  -- ou outro é quem efetivamente pinta a tela.
  hl(0, "@tag", { fg = tn.orange, bold = true })
  hl(0, "@tag.builtin", { fg = tn.orange, bold = true })
  hl(0, "@tag.attribute", { fg = tn.cyan })
  hl(0, "cssTagName", { fg = tn.blue })
  hl(0, "htmlTagName", { fg = tn.blue })
  hl(0, "htmlTag", { fg = tn.comment })
  hl(0, "htmlEndTag", { fg = tn.comment })

  hl(0, "@keyword", { fg = "#FFFFFF", bold = true, italic = true })
  hl(0, "@keyword.function", { fg = "#FFFFFF", bold = true })
  hl(0, "@keyword.return", { fg = "#FFFFFF", bold = true })
  hl(0, "@keyword.operator", { fg = "#FFFFFF", bold = true })
  hl(0, "Keyword", { fg = "#FFFFFF", bold = true, italic = true })
  hl(0, "Statement", { fg = "#FFFFFF", bold = true })
  hl(0, "@type", { fg = "#FFD966", bold = true })
  hl(0, "@type.builtin", { fg = "#FFD966", bold = true })
  hl(0, "Type", { fg = "#FFD966", bold = true })
  hl(0, "@function", { fg = "#8ab4ff", bold = true })
  hl(0, "@function.call", { fg = "#8ab4ff", bold = true })
  hl(0, "Function", { fg = "#8ab4ff", bold = true })
  hl(0, "@variable", { fg = "#F5FAFF" })
  hl(0, "Identifier", { fg = "#F5FAFF" })
  hl(0, "@keyword.conditional", { fg = "#FFFFFF", bold = true, italic = true })
  hl(0, "@keyword.repeat", { fg = "#FFFFFF", bold = true, italic = true })
  hl(0, "@keyword.exception", { fg = "#FFFFFF", bold = true, italic = true })
  hl(0, "@keyword.import", { fg = "#FFFFFF", bold = true })
  hl(0, "@keyword.coroutine", { fg = "#FFFFFF", bold = true })
  hl(0, "@keyword.type", { fg = "#FFFFFF", bold = true })
  hl(0, "@keyword.modifier", { fg = "#FFFFFF", bold = true })
  hl(0, "@keyword.debug", { fg = "#FFFFFF", bold = true })
  hl(0, "@keyword.directive", { fg = "#FFFFFF", bold = true })
  hl(0, "@conditional", { fg = "#FFFFFF", bold = true, italic = true })
  hl(0, "@repeat", { fg = "#FFFFFF", bold = true, italic = true })
  hl(0, "@exception", { fg = "#FFFFFF", bold = true, italic = true })
  hl(0, "@include", { fg = "#FFFFFF", bold = true })
  hl(0, "@storageclass", { fg = "#FFFFFF", bold = true })
  hl(0, "Conditional", { fg = "#FFFFFF", bold = true, italic = true })
  hl(0, "Repeat", { fg = "#FFFFFF", bold = true, italic = true })
  hl(0, "Exception", { fg = "#FFFFFF", bold = true, italic = true })
  hl(0, "Include", { fg = "#FFFFFF", bold = true })
  hl(0, "StorageClass", { fg = "#FFFFFF", bold = true })
  hl(0, "PreProc", { fg = "#FFFFFF", bold = true })
  hl(0, "@keyword.conditional", { fg = "#FFFFFF", bold = true, italic = true })
  hl(0, "@keyword.repeat", { fg = "#FFFFFF", bold = true, italic = true })
  hl(0, "@keyword.exception", { fg = "#FFFFFF", bold = true, italic = true })
  hl(0, "@keyword.import", { fg = "#FFFFFF", bold = true })
  hl(0, "@keyword.coroutine", { fg = "#FFFFFF", bold = true })
  hl(0, "@keyword.type", { fg = "#FFFFFF", bold = true })
  hl(0, "@keyword.modifier", { fg = "#FFFFFF", bold = true })
  hl(0, "@keyword.debug", { fg = "#FFFFFF", bold = true })
  hl(0, "@keyword.directive", { fg = "#FFFFFF", bold = true })
  hl(0, "@conditional", { fg = "#FFFFFF", bold = true, italic = true })
  hl(0, "@repeat", { fg = "#FFFFFF", bold = true, italic = true })
  hl(0, "@exception", { fg = "#FFFFFF", bold = true, italic = true })
  hl(0, "@include", { fg = "#FFFFFF", bold = true })
  hl(0, "@storageclass", { fg = "#FFFFFF", bold = true })
  hl(0, "Conditional", { fg = "#FFFFFF", bold = true, italic = true })
  hl(0, "Repeat", { fg = "#FFFFFF", bold = true, italic = true })
  hl(0, "Exception", { fg = "#FFFFFF", bold = true, italic = true })
  hl(0, "Include", { fg = "#FFFFFF", bold = true })
  hl(0, "StorageClass", { fg = "#FFFFFF", bold = true })
  hl(0, "PreProc", { fg = "#FFFFFF", bold = true })
end

-- SAFE_REQUIRE: pcall mudo trocado por utils/safe_require.lua — ver
-- nota completa em plugins/editing.lua.
require("martini.utils.safe_require")("tokyonight", function(tokyonight)
  local transparent = true

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
    -- Override de fundo/frente pro roxo saturado, em vez do
    -- preto/cinza-azulado padrão do tokyonight-night. Isso é o que
    -- muda a "cara" do tema sem redefinir cada grupo de sintaxe à mão
    -- — o tokyonight recalcula os grupos derivados sozinho.
    on_colors = function(colors)
      -- CORRIGIDO (25/09/2026): faltava o `transparent and ... or ...`
      -- aqui — era o único campo de fundo que ficava sólido mesmo com
      -- transparent=true, cobrindo a opacidade do WezTerm. Ver nota
      -- "BUG DE TRANSPARÊNCIA" no topo do arquivo.
      colors.bg = transparent and colors.none or tn.bg
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
      colors.fg_dark = "#E9F4FF"
      colors.fg_float = tn.fg
      colors.fg_gutter = "#627E97"
      colors.fg_sidebar = "#E9F4FF"
      colors.purple = "#c9b3ff"
      colors.magenta = "#e0c3ff"
      colors.magenta2 = "#ff5fa8"
      colors.blue = "#8ab4ff"
      colors.blue1 = "#5fd0f0"
      colors.cyan = "#a0e9ff"
      colors.green = "#b3e896"
      colors.yellow = "#f0c674"
    end,
  })

  vim.cmd.colorscheme("tokyonight-night")
end, "tema de cores base (tokyonight-night, override roxo saturado)")

aplicar_highlights()

vim.api.nvim_create_autocmd("ColorScheme", { callback = aplicar_highlights })
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function() vim.defer_fn(aplicar_highlights, 300) end,
})
