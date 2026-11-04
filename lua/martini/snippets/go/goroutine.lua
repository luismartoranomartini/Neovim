-- Snippets Go: função anônima chamada na hora (com o () no final)
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  s({ trig = "gof", dscr = "go func() { ... }()" }, fmt("go func() {{\n\t{}\n}}()", { i(1) })),
  s({ trig = "fni", dscr = "func() { ... }() (anônima, chamada na hora)" }, fmt("func() {{\n\t{}\n}}()", { i(1) })),
}
