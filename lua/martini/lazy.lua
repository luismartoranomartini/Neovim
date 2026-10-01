-- =========================================================
-- lua/martini/lazy.lua
-- Bootstrap do lazy.nvim, substituindo loader.lua (set/2026).
--
-- CORTE (18/09/2026): removido jmbuhr/otter.nvim (autocomplete de
-- JS/CSS embutido em HTML — uso raro). Nenhum outro módulo dependia
-- dele.
--
-- VOLTA (18/09/2026): echasnovski/mini.icons tinha entrado no mesmo
-- corte acima (fica sem ícone/cor por tipo de arquivo na listagem do
-- oil), mas voltou — reinstalado abaixo, na mesma posição de antes.
-- require("mini.icons").setup() também voltou em plugins/oil.lua.
--
-- VOLTA (24/09/2026): 3rd/image.nvim também tinha entrado no corte de
-- 18/09 (dependia de ImageMagick no sistema, sem sentido manter em 3
-- plataformas — Arch/Fedora/Windows). Escopo mudou: Windows saiu de
-- cena, Fedora é uso esporádico — sobra só Arch, onde instalar o
-- ImageMagick (`sudo pacman -S imagemagick`) é trivial. Confirmado
-- também que o backend "kitty" funciona no WezTerm (implementa o
-- mesmo protocolo gráfico), que é o terminal usado. Plugin reinstalado
-- abaixo, ver plugins/image.lua pro setup.
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
-- é aplicado em config/colors.lua), nvim-tree.lua e nvim-dap-python
-- (Python fora do escopo atual). bufferline.nvim continua fora: as
-- abas de buffer que aparecem em vídeos de referência não vêm de
-- plugin nenhum — são a tabline NATIVA do Neovim, que já aparece
-- sozinha com 2+ tabpages abertas. <leader>n/<leader>w (config/
-- keymaps.lua) já geram isso sem precisar de código adicional.
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
-- NETRW → OIL (09/09/2026): a troca de "ícones no netrw" (07/09/2026,
-- ver histórico git) foi de vida curta. netrw nativo saiu de cena por
-- completo, junto com prichrd/netrw.nvim e nvim-web-devicons (que só
-- existia como provedor de glyph pro netrw — ver plugins/netrw-icons.lua,
-- REMOVIDO, substituído por plugins/oil.lua).
--
-- ENTROU stevearc/oil.nvim: edita o filesystem como um buffer de texto
-- normal (deletar linha = deletar arquivo, :w aplica). default_file_
-- explorer = true faz oil assumir TODO diretório aberto (nvim ., :e
-- <pasta>) — netrw nunca mais entra em cena, nem como fallback.
--
-- ENTROU echasnovski/mini.icons NO LUGAR de nvim-web-devicons como
-- provedor de ícone — decisão, não default da lib (o README do
-- próprio oil.nvim aceita os dois). Motivo: replicar o setup de
-- referência (github.com/FractalCodeRicardo/dev-config/tree/master/
-- nvim/lua/plugins/oil.lua), pedido explicitamente. Confirmado antes
-- da troca que nada mais na config dependia de nvim-web-devicons:
-- fzf-lua detecta qualquer provedor de ícone instalado em runtime, e
-- os ícones do dashboard (plugins/dashboard.lua) são glyphs Unicode
-- fixos no preset, não chamada a nenhuma lib de ícone.
--
-- NEOGIT (23/09/2026): interface Git interativa dentro do Neovim
-- (status/stage/commit/push/pull), acionada via <leader>v (ver
-- config/keymaps.lua e plugins/neogit.lua pro setup). Depende de
-- nvim-lua/plenary.nvim (obrigatória, adicionada abaixo só por causa
-- disso — nenhum outro plugin da lista precisava dela até agora) e
-- reaproveita ibhagwan/fzf-lua (já instalado acima) pra seleção de
-- menus, sem precisar de telescope.nvim.
--
-- FLASH (25/09/2026): navegação por labels — ver plugins/flash.lua
-- pro setup e as teclas (s/S/r/R/<C-s>, fora da gramática <leader>,
-- convenção do próprio plugin).
--
-- MINI.AI (27/09/2026): text objects a/i genéricos (colchetes, aspas,
-- tag, chamada de função, argumento). Repo mudou de dono em algum
-- momento — hoje mora em nvim-mini/mini.ai, não mais em
-- echasnovski/mini.ai (conta pessoal do autor original). SEM campo
-- "version": README recomenda version=false/'*' pro lazy.nvim, mas
-- esta config já trava tudo por commit exato via lazy-lock.json (ver
-- nota "POR QUE A TROCA" acima) — igual a todo o resto da lista,
-- então o campo ficaria redundante. Substituiu a metade "select" de
-- nvim-treesitter-textobjects (af/if/ac/ic/aa/ia) — ver notas em
-- plugins/textobjects.lua e o novo plugins/mini-ai.lua.
--
-- TINY-INLINE-DIAGNOSTIC (27/09/2026): mensagem de diagnóstico inline
-- com mais destaque que o virtual_text nativo — ver plugins/
-- tiny-inline-diagnostic.lua e a nota "virtual_text NATIVO DESLIGADO"
-- em config/diagnostics.lua (os dois juntos duplicavam a mensagem).
--
-- TINY-CMDLINE (27/09/2026): cmdline como janela flutuante
-- centralizada, via sistema "ui2" nativo do Neovim 0.12 — ver
-- plugins/tiny-cmdline.lua. ATENÇÃO: depende de
-- require("vim._core.ui2"), API interna (prefixo "_core", não em
-- :h), sem garantia de estabilidade entre patches do 0.12.x — ver nota
-- completa no arquivo do plugin.
-- =========================================================

-- BLINK.CMP / MINI.PAIRS / MINI.SURROUND / LUALINE (27/09/2026):
-- troca de stack de completion e de dois plugins de edicao, feita
-- depois que o bug real do <leader> (config/init.lua corrompido) foi
-- corrigido — nada disso tem relacao com aquele bug.
--
-- nvim-cmp + cmp-nvim-lsp + cmp-buffer + cmp_luasnip SAIRAM, entrou
-- saghen/blink.cmp (motor de completion com fuzzy matching nativo,
-- 1 plugin no lugar de 4). LuaSnip continua — vira so o "motor de
-- snippet" que o blink chama (snippets = { preset = "luasnip" } em
-- plugins/completion.lua), nao mais fonte de completion separada.
-- version = "1.*"/"v2.*" (excecao deliberada a convenção de so travar
-- por commit via lazy-lock.json — ver nota "POR QUE A TROCA" no topo
-- deste arquivo): blink.cmp baixa um binario pre-compilado da release
-- marcada por essa tag; sem isso, lazy.nvim tentaria buildar do
-- commit exato e exigiria toolchain Rust (cargo) instalado.
--
-- windwp/nvim-autopairs → nvim-mini/mini.pairs — mesma familia do
-- mini.ai/mini.icons ja em uso. Perde o hook de "depois de aceitar
-- completion" que o nvim-autopairs tinha (nvim-autopairs.completion.cmp)
-- mas mini.pairs nao precisa dele (so reage a tecla digitada).
--
-- kylechui/nvim-surround → nvim-mini/mini.surround — mesma familia.
-- Mapeamentos remapeados pra manter a convencao ys/cs/ds — ver nota
-- completa em plugins/editing.lua.
--
-- ENTROU nvim-lualine/lualine.nvim — substitui a statusline nativa
-- manual (config/options.lua) por branch/diagnostics/filetype prontos.
-- Ver plugins/lualine.lua.
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
  { "nvim-lualine/lualine.nvim", lazy = false }, -- ver nota "BLINK.CMP / MINI.PAIRS / MINI.SURROUND / LUALINE" acima
  -- Dashboard (snacks.nvim) — só o módulo dashboard é usado, ver
  -- plugins/dashboard.lua pro resto desligado de propósito.
  { "folke/snacks.nvim", priority = 1000, lazy = false },
  { "nvim-treesitter/nvim-treesitter",             lazy = false },
  { "nvim-treesitter/nvim-treesitter-textobjects", lazy = false },
  { "L3MON4D3/LuaSnip", version = "v2.*", lazy = false }, -- versao pinada, exigencia do blink.cmp — ver nota "BLINK.CMP" acima
  { "rafamadriz/friendly-snippets", lazy = false },
  { "saghen/blink.cmp", version = "1.*", lazy = false }, -- idem — baixa binario pre-compilado da release
  { "nvim-mini/mini.pairs", lazy = false },
  { "windwp/nvim-ts-autotag", lazy = false },
  { "nvim-mini/mini.surround", lazy = false },
  { "mattn/emmet-vim",        lazy = false },
  { "stevearc/conform.nvim",  lazy = false },
  { "mfussenegger/nvim-lint", lazy = false },
  -- LAZY LOADING (01/10/2026), 4º grupo: stack de debug. lazy = true
  -- (sem trigger próprio) — o lazy.nvim carrega cada plugin na PRIMEIRA
  -- vez que algo faz require() do módulo dele. Isso já acontece só sob
  -- demanda: config/keymaps.lua chama martini.plugins.debug.setup() (que
  -- faz require("dap"), require("dapui") e, via languages/go.lua,
  -- require("dap-go")) apenas na primeira ação de debug (<F5>, <leader>d*).
  -- Nenhum arquivo muda além deste.
  { "mfussenegger/nvim-dap",  lazy = true },
  { "nvim-neotest/nvim-nio",  lazy = true },
  { "rcarriga/nvim-dap-ui",   lazy = true },
  { "leoluz/nvim-dap-go",     lazy = true },
  -- LAZY LOADING (01/10/2026), 5º plugin: code_runner carrega no primeiro
  -- :RunCode / :RunProject (<leader>r / <leader>rp). O config roda
  -- plugins/runner.lua, que continua tendo o setup() e a tabela de
  -- comandos por filetype — só deixou de ser chamado no boot (o require
  -- saiu de plugins/init.lua).
  {
    "CRAG666/code_runner.nvim",
    cmd = { "RunCode", "RunFile", "RunProject", "RunClose", "CRFiletype", "CRProjects" },
    config = function()
      require("martini.plugins.runner")
    end,
  },
--   { "mistweaverco/kulala.nvim", lazy = false },
  -- LAZY LOADING (01/10/2026), 6º plugin: multicursor carrega no evento
  -- VeryLazy (logo depois da UI abrir, fora do caminho crítico do boot).
  -- Não dá pra usar keys = {...}: são ~20 atalhos + camada de keymap
  -- dinâmica (addKeymapLayer). O config roda plugins/multicursor.lua,
  -- que mantém o setup() e os atalhos como estavam.
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    event = "VeryLazy",
    config = function()
      require("martini.plugins.multicursor")
    end,
  },
  { "ibhagwan/fzf-lua", lazy = false },
  -- Explorador de arquivos: oil.nvim edita o filesystem como buffer,
  -- substituindo o netrw por completo (ver nota "NETRW → OIL" acima).
  -- mini.icons é o provedor de glyph/cor (não nvim-web-devicons — ver
  -- nota acima pro motivo da escolha).
  { "stevearc/oil.nvim", lazy = false },
  { "echasnovski/mini.icons", lazy = false },
  -- Indicação visual de "arquivo mudou, falta git add/commit"
  -- (09/09/2026): gitsigns.nvim mostra +/~/- por LINHA na coluna de
  -- sinais, dentro do próprio arquivo aberto. oil-git-status.nvim
  -- mostra o status por ARQUIVO dentro da listagem do oil (mesmas
  -- letras do "git status --short": M, A, ?, D...) — dependência
  -- explícita de oil.nvim, só faz sentido com ele instalado. Ver
  -- plugins/gitsigns.lua e a config extra dentro de plugins/oil.lua.
  { "lewis6991/gitsigns.nvim", lazy = false },
  { "refractalize/oil-git-status.nvim", dependencies = { "stevearc/oil.nvim" }, lazy = false },
  { "mason-org/mason.nvim", lazy = false },
  { "abecodes/tabout.nvim", lazy = false },
  -- Interface Git interativa (23/09/2026) — ver nota "NEOGIT" acima.
  -- plenary.nvim é dependência obrigatória do Neogit, exclusiva dele
  -- na lista (nenhum outro plugin aqui precisa dela).
  -- LAZY LOADING (01/10/2026), 1º plugin migrado: neogit só carrega
  -- quando o comando :Neogit roda (<leader>v chama ele). plenary.nvim
  -- não precisa mais de entrada própria — vem como dependência e só
  -- carrega junto com o neogit. O setup() saiu de plugins/neogit.lua
  -- (arquivo removido) e mora aqui, no config do próprio spec.
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Neogit",
    config = function()
      require("neogit").setup({
        integrations = {
          fzf_lua = true,
        },
      })
    end,
  },
  -- Renderização de imagem no buffer (24/09/2026) — ver nota "VOLTA
  -- (24/09/2026)" acima e plugins/image.lua pro setup. Exige
  -- ImageMagick instalado no sistema (fora do controle do lazy.nvim).
  -- LAZY LOADING (01/10/2026), 3º plugin: image.nvim só carrega ao abrir
  -- uma imagem (BufReadPre *.png etc., mesma lista de hijack_file_patterns)
  -- ou um markdown. O setup() saiu de plugins/image.lua (arquivo removido):
  -- aquele arquivo NUNCA era chamado — faltava o require em
  -- plugins/init.lua, então o image.setup() nunca rodava. Agora o config
  -- do spec garante que roda.
  {
    "3rd/image.nvim",
    event = {
      "BufReadPre *.png", "BufReadPre *.jpg", "BufReadPre *.jpeg",
      "BufReadPre *.gif", "BufReadPre *.webp",
    },
    ft = "markdown",
    config = function()
      require("image").setup({
        backend = "kitty",
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
          },
        },
        hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" },
      })
    end,
  },
  -- Navegação por labels (25/09/2026) — ver nota "FLASH" acima e
  -- plugins/flash.lua pro setup.
  -- LAZY LOADING (01/10/2026), 7º plugin: flash em VeryLazy (não só por
  -- tecla) porque modes.search.enabled = true integra com o "/" — se só
  -- carregasse no primeiro "s", o "/" ficaria sem labels até lá. O
  -- config roda plugins/flash.lua, que mantém setup() e atalhos.
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = function()
      require("martini.plugins.flash")
    end,
  },
  -- Text objects a/i genéricos (27/09/2026) — ver nota "MINI.AI"
  -- acima e plugins/mini-ai.lua pro setup.
  { "nvim-mini/mini.ai", lazy = false },
  -- Diagnóstico inline com mais destaque (27/09/2026) — ver nota
  -- "TINY-INLINE-DIAGNOSTIC" acima e plugins/tiny-inline-diagnostic.lua.
  { "rachartier/tiny-inline-diagnostic.nvim", lazy = false },
  -- Cmdline em janela flutuante centralizada (27/09/2026) — ver nota
  -- "TINY-CMDLINE" acima e plugins/tiny-cmdline.lua. Requer Neovim
  -- 0.12+ (já é o mínimo desta config).
  { "rachartier/tiny-cmdline.nvim", lazy = false },
  -- Servidor HTTP local, live-reload (09/09/2026) — necessário pra
  -- htmx (AJAX/fetch não funciona abrindo o HTML direto via file://,
  -- que é o que o runner.lua faz hoje). Sem telescope.nvim nem
  -- which-key.nvim: telescope é só "recomendado" pelo autor, cai em
  -- vim.ui.select se faltar — que no seu caso já é o fzf-lua
  -- (register_ui_select() em finder.lua); which-key é só cosmético
  -- (rótulo do grupo no menu), sem ele os atalhos funcionam igual.
  -- LAZY LOADING (01/10/2026), 2º plugin: live-server só carrega no
  -- primeiro comando :LiveServer* (os <leader>l* chamam esses comandos).
  -- O setup() saiu de plugins/live-server.lua e mora aqui; lá ficaram
  -- só os keymaps.
  {
    "selimacerbas/live-server.nvim",
    cmd = {
      "LiveServerStart", "LiveServerOpen", "LiveServerReload",
      "LiveServerToggleLive", "LiveServerStatus", "LiveServerStop",
      "LiveServerStopAll",
    },
    config = function()
      require("live_server").setup({
        default_port = 8000,
        live_reload = {
          enabled = true,
          inject_script = true,
          debounce = 120,
          css_inject = true, -- troca CSS sem recarregar a página inteira
        },
        directory_listing = {
          enabled = true,
          show_hidden = false,
        },
      })
    end,
  },
  { "smart-splits-nvim/smart-splits.nvim", lazy = false },
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

return primeiro_boot_lazy
