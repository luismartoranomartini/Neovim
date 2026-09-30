-- =========================================================
-- lua/martini/plugins/finder.lua
-- Busca fuzzy de arquivos e texto via fzf-lua — caminho ÚNICO de
-- busca (set/2026: os atalhos nativos <leader>ff/<leader>fg foram
-- removidos de config/keymaps.lua por duplicarem isto aqui).
-- Requisito: binário fzf instalado no sistema.
--
-- <leader>ff/<leader>fg (27/09/2026): antes era <C-p>/<C-g>, trocado
-- por exigir Ctrl + tecla longe do home row. Domínio f (find/arquivos)
-- já existia (<leader>fn, <leader>fd) e ff/fg estavam livres desde a
-- remoção do :find/:grep nativo — mesma gramática <leader>+domínio+verbo.
--
-- LAYOUT (09/09/2026): janela centralizada, mais compacta que o
-- padrão da lib (0.85x0.80) e com preview fixo à direita, sem alternar
-- de posição sozinho — decisão explícita, redesenho completo do
-- winopts padrão. Cores dos highlights FzfLua* (borda, match, cursor,
-- etc.) ficam centralizadas em config/colors.lua, junto de todo o
-- resto da paleta — não aqui.
--
-- SAFE_REQUIRE (09/09/2026): pcall mudo trocado por
-- utils/safe_require.lua — ver nota completa em plugins/editing.lua.
-- =========================================================

local safe_require = require("martini.utils.safe_require")

safe_require("fzf-lua", function(fzf)
  fzf.setup({
    winopts = {
      -- Janela centralizada e mais compacta que o padrão da lib
      -- (0.85x0.80) — ocupa menos tela, foco no que importa.
      height = 0.6,
      width = 0.7,
      row = 0.5,
      col = 0.5,
      border = "rounded",
      title_pos = "center",
      backdrop = 70, -- escurece o resto da tela, dá foco à janela
      preview = {
        default = "bat", -- usa bat se disponível; cai para cat se não
        border = "rounded",
        layout = "horizontal", -- preview sempre à direita, sem alternar
        horizontal = "right:45%",
        title = true,
        title_pos = "center",
        scrollbar = "border",
      },
    },
    files = {
      -- Respeita .gitignore e ignora a pasta .git
      cmd = "fd --type f --hidden --exclude .git",
    },
  })

  -- register_ui_select() faz o fzf-lua assumir QUALQUER vim.ui.select do
  -- Neovim — não só busca de arquivo/grep. Isso troca a lista de texto
  -- simples que aparecia no seletor de configuração do dap-go (F5), e
  -- também code actions do LSP com múltiplas opções, pela mesma janela
  -- flutuante com borda usada no <leader>ff/<leader>fg.
  fzf.register_ui_select()
end, "busca fuzzy de arquivo/texto (<leader>ff/<leader>fg)")

-- =========================================================
-- Atalhos — domínio f (find/arquivos)
-- =========================================================
local map = vim.keymap.set

-- <leader>ff : busca arquivos pelo nome no diretório do projeto
map("n", "<leader>ff", function()
  require("fzf-lua").files()
end, { desc = "Find: buscar arquivos pelo nome" })

-- <leader>fg : busca texto (grep) em todos os arquivos do projeto
map("n", "<leader>fg", function()
  require("fzf-lua").live_grep()
end, { desc = "Find: buscar texto (grep) no projeto" })
