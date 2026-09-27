-- =========================================================
-- lua/martini/plugins/mini-ai.lua
-- nvim-mini/mini.ai (módulo Lua "mini.ai" — nome do repo mudou de
-- dono, o require() não) — text objects a/i genéricos.
--
-- PADRÃO do plugin (nada declarado aqui, já vem pronto):
--   colchetes ( ) [ ] { } < >, aspas ' " `, tag HTML/XML "t",
--   chamada de função "f" (af/if = dentro dos parênteses de foo(...)),
--   argumento "a" (aa/ia), objeto via prompt "?".
--
-- SUBSTITUIU nvim-treesitter-textobjects.select (27/09/2026) — a
-- parte de SELEÇÃO que morava em plugins/textobjects.lua (af/if,
-- ac/ic, aa/ia via Treesitter) saiu de lá pra cá. A parte de
-- NAVEGAÇÃO (]f/[f, ]c/[c) não mudou, continua em textobjects.lua.
--
-- COLISÃO DE TECLAS (decisão 27/09/2026): "af"/"if" e "aa"/"ia" do
-- mini.ai TÊM outro significado do que tinham antes:
--   - "af"/"if" (função) virou CHAMADA de função — só o que está
--     dentro dos parênteses de foo(a, b), não a função inteira.
--   - "aa"/"ia" (argumento) continua sendo argumento, igual antes.
-- Pra não perder o caso "função/struct INTEIRA" que existia antes em
-- af/if/ac/ic, foram criadas duas teclas novas abaixo, via
-- custom_textobjects (reaproveitando as MESMAS queries de Treesitter
-- que .move usa em textobjects.lua):
--   - "aF"/"iF" → função inteira (@function.outer/inner)
--   - "aC"/"iC" → struct/class inteira (@class.outer/inner)
-- custom_textobjects só ACRESCENTA teclas — não desliga os padrões
-- do plugin (documentado em :h MiniAi.config: identificadores não
-- citados mantêm o comportamento embutido).
-- =========================================================

local safe_require = require("martini.utils.safe_require")

safe_require("mini.ai", function(mini_ai)
  local spec_treesitter = mini_ai.gen_spec.treesitter

  mini_ai.setup({
    custom_textobjects = {
      F = spec_treesitter({ a = "@function.outer", i = "@function.inner" }),
      C = spec_treesitter({ a = "@class.outer", i = "@class.inner" }),
    },
  })
end, "text objects a/i (colchetes, aspas, tag, chamada de função, argumento, aF/iF e aC/iC pra função/struct inteira)")
