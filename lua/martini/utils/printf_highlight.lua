-- =========================================================
-- lua/martini/utils/printf_highlight.lua
-- Destaque de verbos de formatação estilo printf (%s, %d, %v, etc.)
-- dentro de strings, via matchadd — o Treesitter não trata esses
-- verbos como nó separado em nenhuma linguagem (fica tudo achatado
-- em @string), então isso é aproximado, não semântico.
--
-- Extraído de languages/go.lua (set/2026) pra ser reaproveitado por
-- qualquer linguagem baseada na convenção printf (Go, C, ...) — o
-- MECANISMO é o mesmo em todas; só o CONJUNTO de letras de verbo
-- válidas muda (C não tem %v/%T/%q/%U, por exemplo). Por isso vive em
-- utils/ (compartilhado) e não dentro de um languages/*.lua específico.
--
-- matchadd() é POR JANELA, não por buffer — por isso a aplicação
-- também dispara em BufWinEnter e WinEnter, com uma flag por janela
-- (prefixada pelo filetype, pra não conflitar entre linguagens
-- diferentes abertas ao mesmo tempo) pra não empilhar matches
-- repetidos toda vez que você troca de janela.
-- =========================================================

local M = {}

-- register(filetype, verbos, modificadores)
--   filetype: string do filetype a observar (ex.: "go", "c")
--   verbos: string com as letras de verbo válidas dessa linguagem,
--           SEM colchetes (ex.: "vTtqxX" pro Go, "diouxX" pro C)
--   modificadores: opcional — alternativas de modificador de
--           comprimento que vêm ANTES do verbo em C (ex.: "l", "ll",
--           "h", "z"), como alternação de regex do Vim separada por
--           "\|" (ex.: "ll\|l\|hh\|h\|z\|j\|t\|L"). Go não usa isso;
--           deixe nil/"" nesse caso.
function M.register(filetype, verbos, modificadores)
  local flag = "martini_printf_hl_" .. filetype

  local grupo_mod = ""
  if modificadores and modificadores ~= "" then
    -- \%(...\)\= = grupo não-capturante opcional, sintaxe de regex do Vim
    grupo_mod = [=[\%(]=] .. modificadores .. [=[\)\=]=]
  end

  -- Estrutura do printf: %[flags][largura][.precisão][modificador][verbo]
  --   [-+ #0]* → flags, todas opcionais
  --   [0-9]*   → largura, opcional
  --   \.\=[0-9]* → precisão opcional (\.\= = ponto literal opcional;
  --                sem o \=, o "." casaria só se seguido de dígito,
  --                perdendo casos como "%.2f")
  --   grupo_mod → modificador de comprimento opcional (só em C)
  local pattern = [=[%[-+ #0]*[0-9]*\.\=[0-9]*]=] .. grupo_mod .. [=[[]=] .. verbos .. [=[]]=]

  local function aplicar()
    if vim.bo.filetype ~= filetype then return end
    if vim.w[flag] then return end
    vim.fn.matchadd("PrintfVerb", pattern)
    vim.w[flag] = true
  end

  vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter" }, {
    callback = aplicar,
  })
end

return M
