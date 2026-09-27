-- =========================================================
-- lua/martini/config/diagnostics.lua
-- Configuração de vim.diagnostic (extraído de options.lua —
-- diagnósticos são comportamento do editor, não de um plugin,
-- mas mereciam arquivo próprio por serem uma unidade coesa)
--
-- virtual_text NATIVO DESLIGADO (27/09/2026): existia aqui um bloco
-- virtual_text (prefixo "■", estilo Error Lens) — removido e trocado
-- por virtual_text = false de propósito. Motivo: tiny-inline-
-- diagnostic.nvim (ver plugins/tiny-inline-diagnostic.lua) assumiu a
-- mensagem inline; com os dois ligados ao mesmo tempo, a mensagem do
-- diagnóstico aparecia DUAS vezes na mesma linha (uma do Neovim
-- nativo, outra do plugin).
-- =========================================================

local sev = vim.diagnostic.severity

vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [sev.ERROR] = "E",
      [sev.WARN] = "W",
      [sev.INFO] = "I",
      [sev.HINT] = "H",
    },
  },
  -- Ver nota "virtual_text NATIVO DESLIGADO" acima.
  virtual_text = false,
})
