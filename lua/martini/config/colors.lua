-- =========================================================
-- lua/martini/config/colors.lua
-- Tema base: tokyonight-night, paleta reduzida (01/10/2026).
--
-- Objetivo: menos cores, mais leve. A sintaxe usa só 4 cores de
-- destaque + cinza + texto:
--   branco  -> palavras-chave (negrito + itálico)
--   azul    -> funções (negrito + itálico) e tags
--   amarelo -> tipos, números e constantes
--   verde   -> strings
--   cinza   -> comentários e parâmetros
--   texto   -> variáveis, operadores e pontuação
-- Negrito/itálico só em palavras-chave e funções. Vermelho/laranja ficam só para
-- sinais funcionais (erro, git, DAP).
--
-- O fundo é transparente: o roxo vem da imagem do WezTerm.
-- bg/bg_dark/bg_hl só aparecem em CursorLine, popups e tabline.
-- =========================================================

local tn = {
  bg_dark = "#211934",
  bg = "#2e2440",
  bg_hl = "#453465",
  fg = "#f5faff",
  white = "#ffffff",
  gray = "#a3a9cc",
  purple = "#d6c4ff",
  blue = "#9cc2ff",
  yellow = "#ffd980",
  green = "#c2f0a4",
  -- (12/10/2026) verde mais escuro SÓ para strings, para os verbos
  -- (amarelo) se destacarem. Quer ainda mais escuro? Troque este valor.
  green_str = "#9ece6a",
  yellow_verb = "#ffe600", -- verbos printf: amarelo forte, sem bold
  -- só sinais funcionais (não usados em sintaxe)
  red = "#f7768e",
  orange = "#ff9e64",
}

local function aplicar_highlights()
  local hl = vim.api.nvim_set_hl

  -- ---------- Sintaxe ----------
  hl(0, "Keyword", { fg = tn.white, bold = true, italic = true })
  hl(0, "Statement", { fg = tn.white, bold = true, italic = true })
  hl(0, "Conditional", { fg = tn.white, bold = true, italic = true })
  hl(0, "Repeat", { fg = tn.white, bold = true, italic = true })
  hl(0, "Exception", { fg = tn.white, bold = true, italic = true })
  hl(0, "Include", { fg = tn.white, bold = true, italic = true })
  hl(0, "StorageClass", { fg = tn.white, bold = true, italic = true })
  hl(0, "PreProc", { fg = tn.white, bold = true, italic = true })
  hl(0, "@keyword", { fg = tn.white, bold = true, italic = true })
  hl(0, "@keyword.function", { fg = tn.white, bold = true, italic = true })
  hl(0, "@keyword.return", { fg = tn.white, bold = true, italic = true })
  hl(0, "@keyword.operator", { fg = tn.white, bold = true, italic = true })
  hl(0, "@keyword.conditional", { fg = tn.white, bold = true, italic = true })
  hl(0, "@keyword.repeat", { fg = tn.white, bold = true, italic = true })
  hl(0, "@keyword.exception", { fg = tn.white, bold = true, italic = true })
  hl(0, "@keyword.import", { fg = tn.white, bold = true, italic = true })
  hl(0, "@keyword.coroutine", { fg = tn.white, bold = true, italic = true })
  hl(0, "@keyword.type", { fg = tn.white, bold = true, italic = true })
  hl(0, "@keyword.modifier", { fg = tn.white, bold = true, italic = true })
  hl(0, "@keyword.directive", { fg = tn.white, bold = true, italic = true })

  hl(0, "Function", { fg = tn.blue, bold = true, italic = true })
  hl(0, "@function", { fg = tn.blue, bold = true, italic = true })
  hl(0, "@function.call", { fg = tn.blue, bold = true, italic = true })
  hl(0, "@function.method", { fg = tn.blue, bold = true, italic = true })
  hl(0, "@function.method.call", { fg = tn.blue, bold = true, italic = true })

  hl(0, "Type", { fg = tn.yellow })
  hl(0, "@type", { fg = tn.yellow })
  hl(0, "@type.builtin", { fg = tn.yellow })
  hl(0, "Number", { fg = tn.yellow })
  hl(0, "Constant", { fg = tn.yellow })
  hl(0, "@number", { fg = tn.yellow })
  hl(0, "@constant", { fg = tn.yellow })
  hl(0, "@constant.builtin", { fg = tn.yellow })
  hl(0, "Boolean", { fg = tn.yellow })

  hl(0, "String", { fg = tn.green_str })
  hl(0, "@string", { fg = tn.green_str })

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
  hl(0, "PrintfVerb", { fg = tn.yellow_verb, bold = false })
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

  -- telescope.nvim (13/10/2026, trocou o fzf-lua) — borda cinza, títulos
  -- azuis, match em amarelo. FUNDO TRANSPARENTE ("NONE"), como o resto
  -- da config: o roxo é a imagem do WezTerm aparecendo por trás. Só a
  -- linha selecionada tem fundo (bg_hl). Quer o painel sólido de volta?
  -- Troque "NONE" por tn.bg_dark nas linhas abaixo.
  hl(0, "TelescopeNormal", { bg = "NONE" })
  hl(0, "TelescopeBorder", { fg = tn.gray, bg = "NONE" })
  hl(0, "TelescopePromptNormal", { bg = "NONE" })
  hl(0, "TelescopePromptBorder", { fg = tn.gray, bg = "NONE" })
  hl(0, "TelescopePromptTitle", { fg = tn.blue, bold = true })
  hl(0, "TelescopePromptPrefix", { fg = tn.blue, bold = true })
  hl(0, "TelescopeResultsNormal", { bg = "NONE" })
  hl(0, "TelescopeResultsBorder", { fg = tn.gray, bg = "NONE" })
  hl(0, "TelescopeResultsTitle", { fg = tn.blue, bold = true })
  hl(0, "TelescopePreviewNormal", { bg = "NONE" })
  hl(0, "TelescopePreviewBorder", { fg = tn.gray, bg = "NONE" })
  hl(0, "TelescopePreviewTitle", { fg = tn.blue, bold = true })
  hl(0, "TelescopeSelection", { bg = tn.bg_hl })
  hl(0, "TelescopeSelectionCaret", { fg = tn.green, bg = tn.bg_hl })
  hl(0, "TelescopeMultiSelection", { fg = tn.purple })
  hl(0, "TelescopeMatching", { fg = tn.yellow, bold = true })
end

require("martini.utils.safe_require")("tokyonight", function(tokyonight)
  local transparent = true

  tokyonight.setup({
    style = "night",
    transparent = transparent,
    styles = {
      comments = { italic = true },
      keywords = { bold = true, italic = true },
      functions = { bold = true, italic = true },
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
      colors.fg_gutter = "#9a94c4"
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
  callback = function()
    vim.defer_fn(aplicar_highlights, 300)
  end,
})
