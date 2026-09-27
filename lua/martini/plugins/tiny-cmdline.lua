-- =========================================================
-- lua/martini/plugins/tiny-cmdline.lua
-- rachartier/tiny-cmdline.nvim — reposiciona a cmdline (:, /, comandos
-- Ex) como uma janela flutuante centralizada, em cima do sistema
-- "ui2" nativo do Neovim 0.12 (ver checagem nvim-0.12 em
-- lua/martini/init.lua). vim.opt.cmdheight = 0 (requisito do plugin)
-- já está setado em config/options.lua.
--
-- O plugin é "setup-less": ele mesmo se auto-inicializa no evento
-- UIEnter com valores padrão, mesmo sem chamar setup(). A chamada
-- abaixo é só pra deixar a configuração explícita, na mesma convenção
-- do resto da config (nada de comportamento implícito não documentado
-- aqui).
--
-- ATENÇÃO (27/09/2026, NÃO CONFIRMADO em uso real ainda): o README do
-- plugin pede require("vim._core.ui2").enable({}) ANTES dele
-- carregar — API INTERNA do Neovim (prefixo "_core", fora de :h),
-- sem garantia de estar no mesmo lugar ou de continuar existindo em
-- patches futuros do 0.12.x. Se depois de instalar a cmdline continuar
-- aparecendo embaixo do jeito de sempre (sem virar janela flutuante),
-- os pontos a checar, nessa ordem:
--   1. :messages / :checkhealth — ver se apareceu erro do pcall abaixo
--      (nome/caminho do módulo pode ter mudado).
--   2. Mover este require("vim._core.ui2").enable({}) pro TOPO de
--      lua/martini/init.lua, antes até do bootstrap do lazy.nvim — pode
--      ser tarde demais rodar isso aqui, depois de plugins/init.lua já
--      ter carregado boa parte da config, em relação ao momento em que
--      o Neovim dispara UIEnter.
-- =========================================================

local safe_require = require("martini.utils.safe_require")

local ok_ui2, ui2 = pcall(require, "vim._core.ui2")
if ok_ui2 then
  ui2.enable({})
else
  vim.notify(
    "martini.nvim: vim._core.ui2 não encontrado — tiny-cmdline.nvim não vai funcionar. "
      .. "API interna do Neovim 0.12, pode ter mudado de nome/local (ver nota no topo de plugins/tiny-cmdline.lua).",
    vim.log.levels.WARN
  )
end

safe_require("tiny-cmdline", function(tiny_cmdline)
  tiny_cmdline.setup({})
end, "cmdline em janela flutuante centralizada (tiny-cmdline.nvim)")
