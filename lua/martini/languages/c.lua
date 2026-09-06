-- =========================================================
-- lua/martini/languages/c.lua
-- Tudo que é específico de C, consolidado num único lugar (mesmo
-- padrão de languages/go.lua).
-- =========================================================

-- =========================================================
-- Highlight: verbos de formatação do C (printf/scanf/fprintf/etc.),
-- mecanismo compartilhado — ver utils/printf_highlight.lua.
-- Conjunto de verbos do C: d i o u x X e E f F g G a A c s p n %
-- (cppreference — printf format string)
-- Modificadores de comprimento (vêm ANTES do verbo, ex.: %ld, %zu,
-- %lld): l, ll, h, hh, z (size_t), j (intmax_t), t (ptrdiff_t), L
-- (long double). Ordem importa: "ll" precisa vir antes de "l" na
-- alternação, senão o regex casa só o primeiro "l" e sobra um "l"
-- solto sem highlight.
-- =========================================================
require("martini.utils.printf_highlight").register(
  "c",
  "diouxXeEfFgGaAcspn%",
  [=[ll\|l\|hh\|h\|z\|j\|t\|L]=]
)
