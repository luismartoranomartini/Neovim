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
-- (load_extension("ui-select") dentro de setup()).
--
-- LAZY LOADING (14/10/2026): este arquivo NÃO carrega o telescope no
-- boot (economiza ~4 ms). O setup roda UMA vez, no primeiro uso:
--   * <leader>ff / <leader>fg chamam setup() antes do picker;
--   * vim.ui.select é substituído por um wrapper que chama setup() e
--     repete a chamada. Ao carregar, a extensão ui-select troca o
--     vim.ui.select pelo do telescope; se ela falhar, o original é
--     restaurado (evita recursão infinita).
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

local ui_select_original = vim.ui.select
local configurado = false

-- Configura o telescope uma única vez. Retorna true se está pronto.
local function setup()
  if configurado then
    return true
  end
  configurado = true -- marca já: evita reentrada via vim.ui.select

  local pronto = false
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
          -- O padrão do telescope ESCONDE o preview quando o Neovim tem
          -- menos de 120 colunas. 1 = preview sempre visível. (13/10/2026)
          preview_cutoff = 1,
        },
        mappings = {
          i = {
            ["<esc>"] = actions.close,
          },
        },
      },
      pickers = {
        live_grep = { layout_config = { preview_width = 0.45 } },
        find_files = {
          layout_config = { preview_width = 0.45 },
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
      vim.ui.select = ui_select_original
      vim.notify("telescope-ui-select não carregou: " .. tostring(erro), vim.log.levels.WARN)
    end
    pronto = true
  end, "busca fuzzy de arquivo/texto (<leader>ff/<leader>fg)")

  if not pronto then
    vim.ui.select = ui_select_original
  end
  return pronto
end

-- Wrapper provisório: o primeiro vim.ui.select dispara o setup; se a
-- extensão assumiu o vim.ui.select, a chamada é repetida nela.
vim.ui.select = function(...)
  setup()
  return vim.ui.select(...)
end

-- =========================================================
-- Atalhos — domínio f (find/arquivos)
-- =========================================================
local map = vim.keymap.set

-- <leader>ff : busca arquivos pelo nome no diretório do projeto
map("n", "<leader>ff", function()
  if setup() then
    require("telescope.builtin").find_files()
  end
end, { desc = "Find: buscar arquivos pelo nome" })

-- <leader>fg : busca texto (grep) em todos os arquivos do projeto
map("n", "<leader>fg", function()
  if setup() then
    require("telescope.builtin").live_grep()
  end
end, { desc = "Find: buscar texto (grep) no projeto" })
