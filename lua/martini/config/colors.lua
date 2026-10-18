-- =========================================================
-- lua/martini/config/colors.lua
-- Tema base: omtheme (arquivo colors/omtheme.lua), trocado em 17/10/2026.
-- Antes: tokyonight-night com paleta reduzida (cores mais fortes e
-- fundo roxo). Backup do arquivo antigo: colors.lua.bak
--
-- O omtheme define sintaxe, UI, diagnósticos e telescope. Este arquivo
-- só carrega o tema e reaplica, com a mesma paleta, os grupos que o
-- omtheme não conhece: abas (tabline), status do git no oil, gitsigns,
-- DAP, aviso de arquivo não salvo, verbos printf e tipos builtin.
--
-- O fundo é transparente: a imagem vem do Ghostty.
-- =========================================================

-- Mesmas cores do omtheme (colors/omtheme.lua)
local c = {
  bg_dark = "#141418", -- gray_01
  selection = "#505064",
  fg = "#f0f0ff",
  text = "#c0c0da", -- gray_22
  gray = "#747496", -- gray_12 (legível sobre preto)
  gray_border = "#9696b8", -- gray_16
  red = "#ff80aa",
  orange = "#ffbb99",
  yellow = "#ffd480",
  yellow_verb = "#ffe600", -- verbos printf: amarelo forte
  green = "#00ffbf",
  cyan = "#80d4ff",
  blue = "#80aaff",
  blue_light = "#99bbff",
}

local function aplicar_highlights()
  local hl = vim.api.nvim_set_hl

  -- Tipos builtin (int, string, bool...): mesma cor de Type.
  -- Os grupos continuam definidos porque utils/type_highlight.lua
  -- e languages/go.lua os referenciam.
  for _, g in ipairs({ "TypeInt", "TypeString", "TypeBool", "TypeFloat", "TypeError", "TypeByteRune" }) do
    hl(0, g, { fg = c.blue })
  end

  -- Verbos printf (Go, C) e ações de template Go
  hl(0, "PrintfVerb", { fg = c.yellow_verb, bold = false })
  hl(0, "GoTemplateAction", { fg = c.blue_light })
  -- Tela inicial (snacks): caminhos dos arquivos recentes legíveis
  hl(0, "SnacksDashboardDir", { fg = c.gray_border })
  hl(0, "SnacksDashboardFile", { fg = c.text })
  -- Itálico (como era antes do omtheme): pacotes/módulos (fmt), funções, métodos e comentários
  hl(0, "@module", { fg = c.blue, italic = true })
  hl(0, "Function", { fg = c.blue_light, italic = true })
  hl(0, "@function", { fg = c.blue_light, italic = true })
  hl(0, "@function.call", { fg = c.blue_light, italic = true })
  hl(0, "@function.method", { fg = c.blue_light, italic = true })
  hl(0, "@function.method.call", { fg = c.blue_light, italic = true })
  hl(0, "Comment", { fg = "#505068", italic = true })
  hl(0, "@comment", { fg = "#505068", italic = true })

  -- ---------- Sinais funcionais ----------
  -- nvim-dap
  hl(0, "DapBreakpointHl", { fg = c.red })
  hl(0, "DapBreakpointConditionHl", { fg = c.orange })
  hl(0, "DapLogPointHl", { fg = c.blue })
  hl(0, "DapStoppedHl", { fg = c.green })
  hl(0, "DapBreakpointRejectedHl", { fg = c.gray })
  hl(0, "DapStoppedLine", { bg = c.selection })

  -- Statusline: arquivo não salvo
  hl(0, "StatusLineModified", { fg = "#000000", bg = c.orange, bold = true })

  -- gitsigns
  hl(0, "GitSignsAdd", { fg = c.green })
  hl(0, "GitSignsChange", { fg = c.orange })
  hl(0, "GitSignsDelete", { fg = c.red })
  hl(0, "GitSignsTopdelete", { fg = c.red })
  hl(0, "GitSignsChangedelete", { fg = c.orange })
  hl(0, "GitSignsUntracked", { fg = c.gray })

  -- oil: status de git (working tree em tom cheio, índice em itálico)
  local oil = {
    Modified = c.orange,
    Added = c.green,
    Deleted = c.red,
    Untracked = c.blue_light,
    Renamed = c.cyan,
    Copied = c.cyan,
    TypeChanged = c.orange,
    Ignored = c.gray,
    Unmodified = c.gray,
  }
  for nome, cor in pairs(oil) do
    hl(0, "OilGitStatusWorkingTree" .. nome, { fg = cor })
    hl(0, "OilGitStatusIndex" .. nome, { fg = cor, italic = true })
  end
  hl(0, "OilGitStatusWorkingTreeUnmerged", { fg = c.red, bold = true })
  hl(0, "OilGitStatusIndexUnmerged", { fg = c.red, bold = true, italic = true })

  -- Tabline de buffers
  hl(0, "MartiniTabLineSel", { fg = c.fg, bg = c.selection, bold = true })
  hl(0, "MartiniTabLine", { fg = c.gray, bg = c.bg_dark })
  hl(0, "MartiniTabLineFill", { bg = c.bg_dark })
  hl(0, "MartiniTabLineGit", { fg = c.orange, bold = true })

  -- telescope.nvim — borda cinza, títulos azuis, match em amarelo.
  -- FUNDO TRANSPARENTE ("NONE"): a imagem do Ghostty aparece por trás.
  -- Só a linha selecionada tem fundo. Quer o painel sólido de volta?
  -- Troque "NONE" por c.bg_dark nas linhas abaixo.
  hl(0, "TelescopeNormal", { bg = "NONE" })
  hl(0, "TelescopeBorder", { fg = c.gray_border, bg = "NONE" })
  hl(0, "TelescopePromptNormal", { bg = "NONE" })
  hl(0, "TelescopePromptBorder", { fg = c.gray_border, bg = "NONE" })
  hl(0, "TelescopePromptTitle", { fg = c.blue, bold = true })
  hl(0, "TelescopePromptPrefix", { fg = c.blue, bold = true })
  hl(0, "TelescopeResultsNormal", { bg = "NONE" })
  hl(0, "TelescopeResultsBorder", { fg = c.gray_border, bg = "NONE" })
  hl(0, "TelescopeResultsTitle", { fg = c.blue, bold = true })
  hl(0, "TelescopePreviewNormal", { bg = "NONE" })
  hl(0, "TelescopePreviewBorder", { fg = c.gray_border, bg = "NONE" })
  hl(0, "TelescopePreviewTitle", { fg = c.blue, bold = true })
  hl(0, "TelescopeSelection", { bg = c.selection })
  hl(0, "TelescopeSelectionCaret", { fg = c.green, bg = c.selection })
  hl(0, "TelescopeMultiSelection", { fg = c.cyan })
  hl(0, "TelescopeMatching", { fg = c.yellow, bold = true })
end

-- Carrega o omtheme (colors/omtheme.lua). Se faltar o arquivo, avisa
-- em vez de quebrar a inicialização.
local ok, err = pcall(vim.cmd.colorscheme, "omtheme")
if not ok then
  vim.notify(
    "martini.nvim: colorscheme 'omtheme' não encontrado (esperado em ~/.config/nvim/colors/omtheme.lua): "
      .. tostring(err),
    vim.log.levels.WARN
  )
end

aplicar_highlights()

vim.api.nvim_create_autocmd("ColorScheme", { callback = aplicar_highlights })
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function()
    vim.defer_fn(aplicar_highlights, 300)
  end,
})
