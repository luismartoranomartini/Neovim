-- =========================================================
-- lua/martini/plugins/finder.lua
-- Busca fuzzy de arquivos e texto via telescope.nvim — caminho ÚNICO
-- de busca.
-- Requisitos no sistema: ripgrep (rg), obrigatório pro live_grep; fd,
-- recomendado pro find_files. O binário fzf NÃO é mais necessário.
--
-- TROCA fzf-lua → telescope (13/10/2026): pedido explícito. Os atalhos
-- <leader>ff / <leader>fg continuam os mesmos; só o motor mudou.
-- Também mudou quem responde por vim.ui.select (seletor do F5 do
-- dap-go, code actions do LSP com várias opções): antes era
-- fzf.register_ui_select(), agora é a extensão telescope-ui-select
-- (load_extension("ui-select") abaixo).
--
-- LAYOUT: janela centralizada (70% x 60% da tela), com preview fixo à
-- direita (45% da largura), prompt em cima e resultados de cima pra
-- baixo — o mesmo desenho do fzf-lua anterior. Cores dos highlights
-- Telescope* ficam em config/colors.lua, com o resto da paleta.
--
-- <Esc> no modo insert FECHA o picker (no padrão do telescope ele só
-- sai do insert pro normal) — comportamento igual ao do fzf-lua.
--
-- SAFE_REQUIRE (09/09/2026): pcall mudo trocado por
-- utils/safe_require.lua — ver nota completa em plugins/editing.lua.
-- =========================================================

local safe_require = require("martini.utils.safe_require")

safe_require("telescope", function(telescope)
  local actions = require("telescope.actions")
  local themes = require("telescope.themes")

  telescope.setup({
    defaults = {
      layout_strategy = "horizontal",
      sorting_strategy = "ascending", -- melhor resultado no topo
      layout_config = {
        width = 0.7,
        height = 0.6,
        prompt_position = "top",
        preview_width = 0.45,
      },
      mappings = {
        i = {
          ["<esc>"] = actions.close,
        },
      },
    },
    pickers = {
      find_files = {
        -- Respeita .gitignore (o fd faz isso sozinho) e ignora .git
        find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
      },
    },
    extensions = {
      -- Seletor genérico (vim.ui.select) como lista suspensa pequena
      ["ui-select"] = themes.get_dropdown({}),
    },
  })

  -- load_extension DEPOIS do setup (exigência do README da extensão).
  -- Faz o telescope assumir QUALQUER vim.ui.select do Neovim.
  local ok, erro = pcall(telescope.load_extension, "ui-select")
  if not ok then
    vim.notify("telescope-ui-select não carregou: " .. tostring(erro), vim.log.levels.WARN)
  end
end, "busca fuzzy de arquivo/texto (<leader>ff/<leader>fg)")

-- =========================================================
-- Atalhos — domínio f (find/arquivos)
-- =========================================================
local map = vim.keymap.set

-- <leader>ff : busca arquivos pelo nome no diretório do projeto
map("n", "<leader>ff", function()
  require("telescope.builtin").find_files()
end, { desc = "Find: buscar arquivos pelo nome" })

-- <leader>fg : busca texto (grep) em todos os arquivos do projeto
map("n", "<leader>fg", function()
  require("telescope.builtin").live_grep()
end, { desc = "Find: buscar texto (grep) no projeto" })
