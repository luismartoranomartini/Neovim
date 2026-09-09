-- =========================================================
-- lua/martini/plugins/dashboard.lua
-- OPÇÃO 2: tela inicial via snacks.nvim (folke/snacks.nvim).
--
-- Só o módulo "dashboard" fica ligado — todo o resto do snacks.nvim
-- (explorer, picker, notifier, etc.) fica desligado de propósito,
-- porque já temos fzf-lua/nvim-dap/etc. cobrindo isso. Ligar módulos
-- que se sobrepõem ao que já existe é a mesma duplicidade que já
-- reduzimos antes (nvim-tree/fzf-lua, :find/<C-p>).
--
-- REQUISITO: adicionar a entrada abaixo em lua/martini/lazy.lua,
-- na tabela `plugins` (ver RESUMO.md pra instrução completa):
--   { "folke/snacks.nvim", priority = 1000, lazy = false },
--
-- CUSTO: a seção "Git Status" abaixo roda "git status" via processo
-- externo (assíncrono, cacheado por 5 min via `ttl`) — só existe
-- se houver repositório git na pasta aberta (`enabled`). Não tem
-- clima nem CPU/RAM aqui de propósito (evita rede e comandos de
-- sistema específicos de plataforma — ver conversa sobre "o que pesa
-- menos"). Pra adicionar isso depois, é só entrar mais uma seção
-- `terminal` na lista abaixo.
--
-- NETRW → OIL (09/09/2026): tecla "e" do menu trocada de ":Lexplore"
-- pra ":Oil" — netrw saiu de cena por completo (ver notas em
-- lazy.lua e plugins/oil.lua). Ícones deste preset (header/keys) são
-- glyphs Unicode fixos, não vêm de nvim-web-devicons nem mini.icons —
-- por isso a troca de provedor de ícone não afeta nada aqui.
-- =========================================================
require("snacks").setup({
  bigfile = { enabled = false },
  explorer = { enabled = false },
  indent = { enabled = false },
  input = { enabled = false },
  notifier = { enabled = false },
  picker = { enabled = false },
  quickfile = { enabled = false },
  scope = { enabled = false },
  scroll = { enabled = false },
  statuscolumn = { enabled = false },
  words = { enabled = false },
  dashboard = {
    enabled = true,
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
      {
        icon = " ",
        title = "Recent Files",
        section = "recent_files",
        indent = 2,
        padding = 1,
      },
      {
        icon = " ",
        title = "Git Status",
        section = "terminal",
        enabled = function()
          return Snacks.git.get_root() ~= nil
        end,
        cmd = "git status --short --branch",
        height = 5,
        padding = 1,
        ttl = 5 * 60,
        indent = 2,
      },
      { section = "startup" },
    },
    preset = {
      header = table.concat({
        "███╗   ███╗ █████╗ ██████╗ ████████╗██╗███╗   ██╗██╗",
        "████╗ ████║██╔══██╗██╔══██╗╚══██╔══╝██║████╗  ██║██║",
        "██╔████╔██║███████║██████╔╝   ██║   ██║██╔██╗ ██║██║",
        "██║╚██╔╝██║██╔══██║██╔══██╗   ██║   ██║██║╚██╗██║██║",
        "██║ ╚═╝ ██║██║  ██║██║  ██║   ██║   ██║██║ ╚████║██║",
        "╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝╚═╝  ╚═══╝╚═╝",
      }, "\n"),
      -- Mesmas ações do menu que você já usa no resto da config —
      -- fzf-lua pra arquivo/texto, oil pro explorador, :Lazy pros
      -- plugins.
      keys = {
        { icon = " ", key = "n", desc = "New File", action = ":enew" },
        { icon = " ", key = "f", desc = "Find File", action = function() require("fzf-lua").files() end },
        { icon = " ", key = "g", desc = "Find Text", action = function() require("fzf-lua").live_grep() end },
        { icon = " ", key = "e", desc = "Explorer", action = ":Oil" },
        { icon = "󰒲 ", key = "l", desc = "Plugins (Lazy)", action = ":Lazy" },
        { icon = " ", key = "c", desc = "Config", action = ":e $MYVIMRC" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },
  },
})
