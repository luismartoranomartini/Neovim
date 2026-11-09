-- =========================================================
-- lua/martini/plugins/indent.lua
-- lukas-reineke/indent-blankline.nvim (módulo "ibl") — linhas
-- verticais de indentação, como as guias do VSCode.
--
-- Duas camadas:
--   IblIndent -> guia comum de cada nível (discreta)
--   IblScope  -> guia do bloco onde o cursor está (mais forte)
-- Cores da paleta Neon Vivo, redefinidas a cada ColorScheme porque
-- o :colorscheme limpa os grupos de highlight.
--
-- Carregado por lazy.lua (event BufReadPost/BufNewFile), igual ao
-- flash: o config do lazy faz require deste arquivo.
-- =========================================================
local safe_require = require("martini.utils.safe_require")

local function cores()
  vim.api.nvim_set_hl(0, "IblIndent", { fg = "#33334a" })
  vim.api.nvim_set_hl(0, "IblScope", { fg = "#80aaff" })
end

safe_require("ibl", function(ibl)
  cores()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("martini_ibl_cores", { clear = true }),
    callback = cores,
  })

  ibl.setup({
    indent = { char = "│", highlight = "IblIndent" },
    scope = {
      enabled = true,
      highlight = "IblScope",
      show_start = false,
      show_end = false,
    },
    exclude = {
      filetypes = { "help", "dashboard", "lazy", "mason", "oil", "checkhealth", "markdown" },
    },
  })
end, "linhas verticais de indentação (indent-blankline)")
