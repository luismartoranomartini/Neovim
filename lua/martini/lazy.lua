-- =========================================================
-- lua/martini/lazy.lua
-- Bootstrap do lazy.nvim, substituindo loader.lua (set/2026).
--
-- POR QUE A TROCA: loader.lua fazia git clone --depth 1 no branch padrão
-- de cada plugin, sem trava de versão nenhuma — uma config que funciona
-- hoje podia quebrar amanhã com um push de qualquer um dos plugins,
-- sem lockfile, comando de update ou rollback. lazy.nvim resolve isso
-- automaticamente: grava lazy-lock.json com o commit exato de cada
-- plugin após instalar/atualizar. Comitando esse arquivo no repo, toda
-- reinstalação (Arch/Fedora/Windows) usa exatamente as mesmas versões.
--
-- TODOS os plugins abaixo usam lazy = false (carregamento no boot,
-- igual ao loader.lua antigo) DE PROPÓSITO — não é lazy loading de
-- verdade ainda. O resto do código (go.lua, colors.lua, debug.lua, etc.)
-- faz require() desses plugins diretamente no topo do arquivo, assumindo
-- que já estão no runtimepath quando plugins/init.lua roda. Lazy
-- loading por evento (InsertEnter, BufReadPost, cmd, etc.) exigiria
-- refatorar esses requires em cada plugins/*.lua pra rodar sob demanda
-- — mudança maior, fora do escopo desta correção. O ganho aqui é
-- reprodutibilidade automática, não redução de tempo de boot.
--
-- ESCOPO REDUZIDO (set/2026): lista trimada a Go, JS/TS (web) e C —
-- removidos onedark.nvim, nightfox.nvim (nunca usados — só tokyonight
-- é aplicado em config/colors.lua), nvim-tree.lua, nvim-web-devicons,
-- bufferline.nvim (não pedidos; <leader>e agora usa :Lexplore nativo)
-- e nvim-dap-python (Python fora do escopo atual).
--
-- CORREÇÃO (07/09/2026): a versão anterior rodava
-- require("lazy").update({ show = false }) sozinha ~1s depois do
-- VimEnter, TODA VEZ que o Neovim abria. Isso contradizia o próprio
-- motivo de ter o lazy-lock.json: o lockfile existe pra fixar os
-- commits e tornar a instalação previsível/reprodutível, mas a
-- atualização automática regravava esse mesmo arquivo sozinha a cada
-- boot, sem aviso — ou seja, os commits "fixados" mudavam por conta
-- própria, silenciosamente, antes de qualquer validação sua. Trocado
-- por um comando explícito (:MartiniUpdate) — mesmo espírito do
-- :MartiniUpdatePlugins que o loader.lua antigo tinha, só que
-- delegando pra API do próprio lazy.nvim em vez de git pull cru.
--
-- ÍCONES NO NETRW (07/09/2026): nvim-web-devicons volta à lista, mas
-- só como PROVEDOR de glyphs — não é o mesmo cenário do nvim-tree
-- removido acima. Some junto prichrd/netrw.nvim, que não substitui o
-- netrw (continua sendo o :Lexplore nativo, mesmas teclas mf/mt/mc/
-- mm/mu), apenas intercepta a renderização do buffer pra desenhar um
-- ícone por linha usando esse provedor. Nenhuma tecla muda.
-- =========================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local primeiro_boot_lazy = vim.fn.isdirectory(lazypath) == 0
if primeiro_boot_lazy then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Mesma sintaxe { "dono/repo", branch = "x" } já usada pro
-- multicursor.nvim — lazy.nvim entende esse formato nativamente.
local plugins = {
  { "folke/tokyonight.nvim", lazy = false },
  { "jmbuhr/otter.nvim", lazy = false },
  -- Dashboard (snacks.nvim) — só o módulo dashboard é usado, ver
  -- plugins/dashboard.lua pro resto desligado de propósito.
  { "folke/snacks.nvim", priority = 1000, lazy = false },
  { "nvim-treesitter/nvim-treesitter",             lazy = false },
  { "nvim-treesitter/nvim-treesitter-textobjects", lazy = false },
  { "hrsh7th/nvim-cmp",         lazy = false },
  { "hrsh7th/cmp-nvim-lsp",     lazy = false },
  { "hrsh7th/cmp-buffer",       lazy = false },
  { "L3MON4D3/LuaSnip",         lazy = false },
  { "saadparwaiz1/cmp_luasnip", lazy = false },
  { "rafamadriz/friendly-snippets", lazy = false },
  { "windwp/nvim-autopairs",  lazy = false },
  { "windwp/nvim-ts-autotag", lazy = false },
  { "kylechui/nvim-surround", lazy = false },
  { "mattn/emmet-vim",        lazy = false },
  { "stevearc/conform.nvim",  lazy = false },
  { "mfussenegger/nvim-lint", lazy = false },
  { "mfussenegger/nvim-dap",  lazy = false },
  { "nvim-neotest/nvim-nio",  lazy = false },
  { "rcarriga/nvim-dap-ui",   lazy = false },
  { "leoluz/nvim-dap-go",     lazy = false },
  { "CRAG666/code_runner.nvim", lazy = false },
  { "mistweaverco/kulala.nvim", lazy = false },
  { "jake-stewart/multicursor.nvim", branch = "1.0", lazy = false },
  { "ibhagwan/fzf-lua", lazy = false },
  -- Ícones no netrw (ver nota acima) — nvim-web-devicons é só o
  -- provedor de glyphs, netrw.nvim é quem desenha na tela do :Lexplore.
  { "nvim-tree/nvim-web-devicons", lazy = false },
  { "prichrd/netrw.nvim", lazy = false },
}

-- Detecta se algum plugin ainda não foi clonado ANTES de chamar setup()
-- — mesma lógica de "primeiro_boot" que loader.lua tinha, só que agora
-- delegando a instalação em si pro lazy.nvim (install.missing = true).
local plugins_root = vim.fn.stdpath("data") .. "/lazy/"
local faltando = false
for _, spec in ipairs(plugins) do
  local repo = spec[1]
  local nome = repo:match(".*/(.*)")
  if vim.fn.isdirectory(plugins_root .. nome) == 0 then
    faltando = true
    break
  end
end

require("lazy").setup(plugins, {
  root = plugins_root,
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
  install = { missing = true },
  -- checker fica desligado: a atualização agora é 100% manual, via
  -- :MartiniUpdate (ver comando abaixo) — não queremos nem o
  -- check+notify nativo do lazy.nvim rodando em background sozinho.
  checker          = { enabled = false },
  change_detection = { notify = false },
})

-- =========================================================
-- :MartiniUpdate — atualização MANUAL e explícita dos plugins.
-- Substitui o autocmd de VimEnter que rodava update() sozinho a cada
-- boot (ver nota de correção no topo do arquivo). Abre a UI do
-- lazy.nvim (show = true, ao contrário do comportamento antigo) pra
-- você ver o que mudou e decidir, em vez de aceitar tudo às cegas.
-- O lazy-lock.json só é regravado quando você rodar isso de propósito.
-- =========================================================
vim.api.nvim_create_user_command("MartiniUpdate", function()
  require("lazy").update()
end, { desc = "Atualiza os plugins do lazy.nvim manualmente (regrava lazy-lock.json)" })

return primeiro_boot_lazy or faltando
