-- =========================================================
-- lua/martini/plugins/lualine.lua
-- Substitui a statusline nativa manual que morava em config/options.lua
-- (27/09/2026) — branch, diagnostics e filetype prontos, sem precisar
-- montar a string de 'statusline' a mao. mini.icons (ja instalado) e
-- detectado automaticamente pelo lualine pro icone de filetype/arquivo,
-- nao precisa de nvim-web-devicons.
--
-- AVISO DE ARQUIVO NAO SALVO: o componente customizado "unsaved"
-- abaixo reproduz o antigo aviso "● UNSAVED" (mais chamativo que o
-- [+] padrao), lendo a cor do highlight DiagnosticWarn em tempo real
-- (ja definido em config/diagnostics.lua) — nao um hex fixo, pra
-- acompanhar sozinho se a paleta de colors.lua mudar.
-- =========================================================

local safe_require = require("martini.utils.safe_require")

safe_require("lualine", function(lualine)
  local function unsaved()
    return vim.bo.modified and "● UNSAVED" or ""
  end

  local function warn_color()
    local hl = vim.api.nvim_get_hl(0, { name = "DiagnosticWarn", link = false })
    return hl.fg and { fg = string.format("#%06x", hl.fg), gui = "bold" } or nil
  end

  lualine.setup({
    options = {
      theme = "tokyonight",
      component_separators = "|",
      section_separators = "",
      globalstatus = true, -- uma barra so, mesmo com splits — evita duplicar em cada painel
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = {
        { unsaved, color = warn_color },
        "branch",
        "diff",
        "diagnostics",
      },
      lualine_c = { { "filename", path = 1 } }, -- path=1: caminho relativo a raiz do projeto
      lualine_x = { "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  })
end, "statusline com branch/diagnostics/filetype prontos (lualine.nvim)")
