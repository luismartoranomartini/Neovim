-- =========================================================
-- lua/martini/plugins/textobjects.lua
-- nvim-treesitter-textobjects (branch main) — usado aqui só pra
-- NAVEGAÇÃO entre função/struct (]f/[f, ]c/[c, via .move).
--
-- SELEÇÃO SAIU DAQUI (27/09/2026): af/if (função), ac/ic (struct/
-- class) e aa/ia (parâmetro) via .select() foram substituídos pelo
-- mini.ai — ver plugins/mini-ai.lua. Motivo: mini.ai cobre bem mais
-- casos com a mesma mecânica a/i (colchetes, aspas, tag, chamada de
-- função) e evita manter dois plugins de text object fazendo a
-- mesma coisa. O plugin nvim-treesitter-textobjects continua
-- instalado só por causa do módulo .move (usado abaixo) e das
-- queries de Treesitter que ele registra (as mesmas que
-- MiniAi.gen_spec.treesitter reaproveita em mini-ai.lua, pras teclas
-- novas aF/iF e aC/iC).
--
-- API nova (pós-reescrita): sem require("nvim-treesitter.configs").
-- Keymap setado manualmente via o módulo .move.
--
-- SAFE_REQUIRE (09/09/2026): pcalls mudos trocados por
-- utils/safe_require.lua — ver nota completa em plugins/editing.lua.
-- move usa safe_require.get() (não a forma chamável) porque os
-- keymaps só fazem sentido condicionados à presença do módulo, não é
-- um "setup imediato".
-- =========================================================

local safe_require = require("martini.utils.safe_require")

-- Desativa mapeamentos automáticos de ftplugins nativos que colidiriam
-- com os keymaps abaixo (ex.: [[/]] em alguns filetypes)
vim.g.no_plugin_maps = true

safe_require("nvim-treesitter-textobjects", function(textobjects)
  textobjects.setup({
    move = {
      set_jumps = true, -- registra posição na jumplist (Ctrl-o/Ctrl-i funcionam)
    },
  })
end, "navegação entre função/struct (]f/[f, ]c/[c)")

-- ── Move: ]f / [f pula entre funções, ]c / [c entre structs/classes ──
local move = safe_require.get("nvim-treesitter-textobjects.move", "navegação entre função/struct (]f/[f, ]c/[c)")
if move then
  local function goto_next(query) return function() move.goto_next_start(query, "textobjects") end end
  local function goto_prev(query) return function() move.goto_previous_start(query, "textobjects") end end

  vim.keymap.set({ "n", "x", "o" }, "]f", goto_next("@function.outer"), { desc = "Próxima função" })
  vim.keymap.set({ "n", "x", "o" }, "]c", goto_next("@class.outer"), { desc = "Próxima struct/class" })
  vim.keymap.set({ "n", "x", "o" }, "[f", goto_prev("@function.outer"), { desc = "Função anterior" })
  vim.keymap.set({ "n", "x", "o" }, "[c", goto_prev("@class.outer"), { desc = "Struct/class anterior" })
end
