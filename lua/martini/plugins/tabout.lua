-- =========================================================
-- lua/martini/plugins/tabout.lua
-- <Tab> pula pra fora de aspas/parênteses/chaves quando o cursor está
-- logo antes de um fechamento (26/09/2026).
--
-- backwards_tabkey = "" DE PROPÓSITO: <S-Tab> continua 100% do
-- completion.lua (cmp.select_prev_item() / fallback nativo) — não
-- queremos o tabout competindo por essa tecla também.
--
-- completion = true: quando o menu do nvim-cmp está visível, o
-- tabout deixa o cmp navegar (select_next_item) em vez de tentar
-- pular — evita competir com completion.lua pro <Tab> nesse caso.
-- Fora do menu de completion, é aqui que o pulo de fato acontece.
--
-- Filetypes de Emmet (html/css/scss/jsx/tsx) sobrescrevem <Tab> com
-- mapeamento LOCAL AO BUFFER em completion.lua — mapeamento local
-- sempre tem prioridade sobre o global daqui, então o Emmet continua
-- funcionando exatamente como antes nesses 5 filetypes.
-- =========================================================
require("martini.utils.safe_require")("tabout", function(tabout)
  tabout.setup({
    tabkey = "<Tab>",
    backwards_tabkey = "",
    act_as_tab = true, -- sem nada pra pular, <Tab> volta a indentar normalmente
    act_as_shift_tab = false,
    enable_backwards = false,
    completion = true,
    tabouts = {
      { open = "'", close = "'" },
      { open = '"', close = '"' },
      { open = "`", close = "`" },
      { open = "(", close = ")" },
      { open = "[", close = "]" },
      { open = "{", close = "}" },
    },
    ignore_beginning = true,
    exclude = {},
  })
end, "pular pra fora de aspas/parênteses/chaves com Tab (tabout.nvim)")
