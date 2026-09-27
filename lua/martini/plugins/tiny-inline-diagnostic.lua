-- =========================================================
-- lua/martini/plugins/tiny-inline-diagnostic.lua
-- rachartier/tiny-inline-diagnostic.nvim — mensagem de diagnóstico
-- inline com mais destaque/formatação que o virtual_text nativo do
-- Neovim (ícone, cor de fundo, corte de mensagem longa, etc.).
-- Requer Neovim >= 0.10 — bem abaixo do 0.12 mínimo desta config,
-- sem risco de incompatibilidade.
--
-- virtual_text NATIVO DESLIGADO (27/09/2026): ver a nota
-- "virtual_text NATIVO DESLIGADO" em config/diagnostics.lua — esse
-- plugin assume sozinho a mensagem inline; com os dois ligados ao
-- mesmo tempo, a mensagem aparecia duas vezes na mesma linha.
-- =========================================================

local safe_require = require("martini.utils.safe_require")

safe_require("tiny-inline-diagnostic", function(tiny_inline_diagnostic)
  tiny_inline_diagnostic.setup({
    preset = "modern",
  })
end, "mensagem de diagnóstico inline com mais destaque (tiny-inline-diagnostic.nvim)")
