-- =========================================================
-- lua/martini/config/colors.lua
-- Tema base: tokyonight-night, paleta reduzida (01/10/2026).
--
-- Objetivo: menos cores, mais leve. A sintaxe usa só 4 cores de
-- destaque + cinza + texto:
--   roxo    -> palavras-chave
--   azul    -> funções e tags
--   amarelo -> tipos, números e constantes
--   verde   -> strings
--   cinza   -> comentários e parâmetros
--   texto   -> variáveis, operadores e pontuação
-- Sem negrito/itálico forçado. Vermelho/laranja ficam só para
-- sinais funcionais (erro, git, DAP).
--
-- O fundo é transparente: o roxo vem da imagem do WezTerm.
-- bg/bg_dark/bg_hl só aparecem em CursorLine, popups e tabline.
-- =========================================================

local tn = {
  bg_dark = "#211934",
  bg      = "#2e2440",
  bg_hl   = "#453465",
  fg      = "#e6e1f0",
  gray    = "#7a7f9e",
  purple  = "#c9b3ff",
  blue    = "#8ab4ff",
  yellow  = "#f0c674",
  green   = "#b3e896",
  -- só sinais funcionais (não usados em sintaxe)
  red     = "#f7768e",
  orange  = "#ff9e64",
}

local function aplicar_highlights()
  local hl = vim.api.nvim_set_hl

  -- ---------- Sintaxe ----------
  hl(0, "Keyword", { fg = tn.purple })
  hl(0, "Statement", { fg = tn.purple })
  hl(0, "Conditional", { fg = tn.purple })
  hl(0, "Repeat", { fg = tn.purple })
  hl(0, "Exception", { fg = tn.purple })
  hl(0, "Include", { fg = tn.purple })
  hl(0, "StorageClass", { fg = tn.purple })
  hl(0, "PreProc", { fg = tn.purple })
  hl(0, "@keyword", { fg = tn.purple })
  hl(0, "@keyword.function", { fg = tn.purple })
  hl(0, "@keyword.return", { fg = tn.purple })
  hl(0, "@keyword.operator", { fg = tn.purple })
  hl(0, "@keyword.conditional", { fg = tn.purple })
  hl(0, "@keyword.repeat", { fg = tn.purple })
  hl(0, "@keyword.exception", { fg = tn.purple })
  hl(0, "@keyword.import", { fg = tn.purple })
  hl(0, "@keyword.coroutine", { fg = tn.purple })
  hl(0, "@keyword.type", { fg = tn.purple })
  hl(0, "@keyword.modifier", { fg = tn.purple })
  hl(0, "@keyword.directive", { fg = tn.purple })

  hl(0, "Function", { fg = tn.blue })
  hl(0, "@function", { fg = tn.blue })
  hl(0, "@function.call", { fg = tn.blue })
  hl(0, "@function.method", { fg = tn.blue })
  hl(0, "@function.method.call", { fg = tn.blue })

  hl(0, "Type", { fg = tn.yellow })
  hl(0, "@type", { fg = tn.yellow })
  hl(0, "@type.builtin", { fg = tn.yellow })
  hl(0, "Number", { fg = tn.yellow })
  hl(0, "Constant", { fg = tn.yellow })
  hl(0, "@number", { fg = tn.yellow })
  hl(0, "@constant", { fg = tn.yellow })
  hl(0, "@constant.builtin", { fg = tn.yellow })
  hl(0, "Boolean", { fg = tn.yellow })

  hl(0, "String", { fg = tn.green })
  hl(0, "@string", { fg = tn.green })

  hl(0, "Identifier", { fg = tn.fg })
  hl(0, "@variable", { fg = tn.fg })
  hl(0, "@property", { fg = tn.fg })
  hl(0, "Operator", { fg = tn.fg })
  hl(0, "Delimiter", { fg = tn.fg })
  hl(0, "@operator", { fg = tn.fg })
  hl(0, "@punctuation", { fg = tn.fg })
  hl(0, "@punctuation.delimiter", { fg = tn.fg })
  hl(0, "@punctuation.bracket", { fg = tn.fg })

  -- Parâmetros: cinza, para não competir com tipo/variável
  hl(0, "@lsp.type.parameter", { fg = tn.gray })
  hl(0, "@variable.parameter", { fg = tn.gray })
  hl(0, "@parameter", { fg = tn.gray })

  -- Tipos builtin (int, string, bool...): mesma cor de Type.
  -- Os grupos continuam definidos porque utils/type_highlight.lua
  -- e languages/go.lua os referenciam.
  for _, g in ipairs({ "TypeInt", "TypeString", "TypeBool", "TypeFloat", "TypeError", "TypeByteRune" }) do
    hl(0, g, { fg = tn.yellow })
  end

  -- Verbos printf (Go, C) e ações de template Go
  hl(0, "PrintfVerb", { fg = tn.yellow })
  hl(0, "GoTemplateAction", { fg = tn.purple })

  -- Tags HTML/CSS/JSX
  hl(0, "@tag", { fg = tn.blue })
  hl(0, "@tag.builtin", { fg = tn.blue })
  hl(0, "@tag.attribute", { fg = tn.yellow })
  hl(0, "cssTagName", { fg = tn.blue })
  hl(0, "htmlTagName", { fg = tn.blue })
  hl(0, "htmlTag", { fg = tn.gray })
  hl(0, "htmlEndTag", { fg = tn.gray })

  -- ---------- Sinais funcionais ----------
  -- nvim-dap
  hl(0, "DapBreakpointHl", { fg = tn.red })
  hl(0, "DapBreakpointConditionHl", { fg = tn.orange })
  hl(0, "DapLogPointHl", { fg = tn.blue })
  hl(0, "DapStoppedHl", { fg = tn.green })
  hl(0, "DapBreakpointRejectedHl", { fg = tn.gray })
  hl(0, "DapStoppedLine", { bg = tn.bg_hl })

  -- Statusline: arquivo não salvo
  hl(0, "StatusLineModified", { fg = "#000000", bg = tn.orange, bold = true })

  -- gitsigns
  hl(0, "GitSignsAdd", { fg = tn.green })
  hl(0, "GitSignsChange", { fg = tn.orange })
  hl(0, "GitSignsDelete", { fg = tn.red })
  hl(0, "GitSignsTopdelete", { fg = tn.red })
  hl(0, "GitSignsChangedelete", { fg = tn.orange })
  hl(0, "GitSignsUntracked", { fg = tn.gray })

  -- oil: status de git (working tree em tom cheio, índice em itálico)
  local oil = {
    Modified = tn.orange,
    Added = tn.green,
    Deleted = tn.red,
    Untracked = tn.blue,
    Renamed = tn.purple,
    Copied = tn.purple,
    TypeChanged = tn.orange,
    Ignored = tn.gray,
    Unmodified = tn.gray,
  }
  for nome, cor in pairs(oil) do
    hl(0, "OilGitStatusWorkingTree" .. nome, { fg = cor })
    hl(0, "OilGitStatusIndex" .. nome, { fg = cor, italic = true })
  end
  hl(0, "OilGitStatusWorkingTreeUnmerged", { fg = tn.red, bold = true })
  hl(0, "OilGitStatusIndexUnmerged", { fg = tn.red, bold = true, italic = true })

  -- Tabline de buffers
  hl(0, "MartiniTabLineSel", { fg = tn.fg, bg = tn.bg_hl, bold = true })
  hl(0, "MartiniTabLine", { fg = tn.gray, bg = tn.bg_dark })
  hl(0, "MartiniTabLineFill", { bg = tn.bg_dark })
  hl(0, "MartiniTabLineGit", { fg = tn.orange, bold = true })

  -- fzf-lua
  hl(0, "FzfLuaNormal", { bg = tn.bg_dark })
  hl(0, "FzfLuaBorder", { fg = tn.gray, bg = tn.bg_dark })
  hl(0, "FzfLuaTitle", { fg = tn.blue, bold = true })
  hl(0, "FzfLuaFzfNormal", { bg = tn.bg_dark })
  hl(0, "FzfLuaFzfBorder", { fg = tn.gray, bg = tn.bg_dark })
  hl(0, "FzfLuaFzfPrompt", { fg = tn.blue, bold = true })
  hl(0, "FzfLuaFzfQuery", { fg = tn.fg })
  hl(0, "FzfLuaFzfMatch", { fg = tn.yellow, bold = true })
  hl(0, "FzfLuaFzfPointer", { fg = tn.green })
  hl(0, "FzfLuaFzfMarker", { fg = tn.purple })
  hl(0, "FzfLuaFzfCursorLine", { bg = tn.bg_hl })
  hl(0, "FzfLuaCursorLine", { bg = tn.bg_hl })
  hl(0, "FzfLuaPreviewNormal", { bg = tn.bg_dark })
  hl(0, "FzfLuaPreviewBorder", { fg = tn.gray, bg = tn.bg_dark })
  hl(0, "FzfLuaPreviewTitle", { fg = tn.blue, bold = true })
  hl(0, "FzfLuaHeaderText", { fg = tn.gray })
  hl(0, "FzfLuaHeaderBind", { fg = tn.gray })
end

require("martini.utils.safe_require")("tokyonight", function(tokyonight)
  local transparent = true

  tokyonight.setup({
    style = "night",
    transparent = transparent,
    styles = {
      comments = { italic = true },
      keywords = { bold = false, italic = false },
      functions = { bold = false },
      sidebars = transparent and "transparent" or "dark",
      floats = transparent and "transparent" or "dark",
    },
    -- Colapsa as ~10 matizes do tokyonight em 4 + cinza. Os grupos
    -- que não sobrescrevemos acima herdam essas cores.
    on_colors = function(colors)
      colors.bg = transparent and colors.none or tn.bg
      colors.bg_dark = transparent and colors.none or tn.bg_dark
      colors.bg_float = transparent and colors.none or tn.bg_dark
      colors.bg_highlight = tn.bg_hl
      colors.bg_popup = tn.bg_dark
      colors.bg_sidebar = transparent and colors.none or tn.bg_dark
      colors.bg_statusline = transparent and colors.none or tn.bg_dark
      colors.bg_search = "#0A64AC"
      colors.bg_visual = "#3a3158"
      colors.border = tn.gray
      colors.comment = tn.gray
      colors.fg = tn.fg
      colors.fg_dark = tn.fg
      colors.fg_float = tn.fg
      colors.fg_gutter = "#5a5478"
      colors.fg_sidebar = tn.fg

      colors.purple = tn.purple
      colors.magenta = tn.purple
      colors.magenta2 = tn.purple
      colors.blue = tn.blue
      colors.blue1 = tn.blue
      colors.blue2 = tn.blue
      colors.blue5 = tn.blue
      colors.blue6 = tn.blue
      colors.blue7 = tn.blue
      colors.cyan = tn.blue
      colors.teal = tn.green
      colors.green = tn.green
      colors.green1 = tn.green
      colors.green2 = tn.green
      colors.yellow = tn.yellow
      colors.orange = tn.yellow
    end,
  })

  vim.cmd.colorscheme("tokyonight-night")
end, "tema de cores base (tokyonight-night, paleta reduzida)")

aplicar_highlights()

vim.api.nvim_create_autocmd("ColorScheme", { callback = aplicar_highlights })
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function() vim.defer_fn(aplicar_highlights, 300) end,
})
