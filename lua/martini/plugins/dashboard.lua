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
-- LOGO EM IMAGEM (09/09/2026): trocado o banner de texto (header) por
-- uma imagem real, via chafa + protocolo gráfico do Kitty (Ghostty já
-- suporta — confirmado no :checkhealth). Mesmo mecanismo que a seção
-- "Git Status" abaixo já usava (rodar um comando de shell dentro de
-- uma seção "terminal"), só que o comando aqui é o chafa em vez do
-- git. O "; sleep .1" no fim é do próprio exemplo oficial do
-- snacks.nvim — dá tempo do terminal liberar a sequência de escape
-- antes do dashboard capturar a saída.
--
-- REQUISITOS pra essa seção funcionar (fora do escopo deste arquivo):
--   1. `chafa` instalado no sistema (pacman -S chafa / dnf install chafa)
--   2. o arquivo assets/martini-logo.png existir dentro da pasta da
--      config (gerado via ImageMagick — comando fora da config, não
--      faz parte do boot do Neovim)
-- Se o arquivo não existir ou chafa não estiver instalado, essa seção
-- fica em branco/com erro do shell — não trava o resto do dashboard,
-- as outras seções continuam funcionando normalmente.
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
      {
        section = "terminal",
        -- --format symbols (NÃO kitty — correção 09/09/2026): essa
        -- seção roda dentro do terminal EMBUTIDO do Neovim
        -- (nvim_open_term, biblioteca libvterm), que entende texto e
        -- cor, mas NÃO o protocolo gráfico do Kitty — mesmo o Ghostty
        -- suportando esse protocolo de verdade (testado fora do
        -- Neovim, funcionou). O protocolo precisa alcançar o terminal
        -- real diretamente; passando pelo terminal virtual do Neovim
        -- no meio, a sequência de escape se perde. "symbols" desenha
        -- com caracteres de meio-bloco Unicode (▀▄) coloridos em vez
        -- de pixel de verdade — mesmo formato do exemplo oficial do
        -- snacks.nvim pra esse caso exato.
        cmd = "chafa " .. vim.fn.stdpath("config") .. "/assets/martini-logo.png --format symbols --symbols vhalf --size 60x17 --stretch; sleep .1",
        height = 17,
        padding = 1,
        -- ttl baixo de propósito (09/09/2026): o padrão do snacks pra
        -- seção "terminal" é 3600s (1h) de cache EM DISCO
        -- (~/.cache/nvim/snacks/<hash>.txt) — inclusive de erro, se o
        -- comando falhar na primeira vez. Foi exatamente isso que
        -- aconteceu ao testar (nome de arquivo errado na primeira
        -- tentativa): nem <leader>fd nem :restart resolviam, porque os
        -- dois liam o mesmo cache antigo. ttl = 5 evita isso se você
        -- trocar a imagem de novo no futuro — sem impacto real, essa
        -- seção não é cara de rodar.
        ttl = 5,
      },
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
