-- =========================================================
-- lua/martini/plugins/http.lua
-- HTTP client (kulala.nvim) — testa APIs via arquivos .http
-- Requisitos: Neovim 0.12+, curl, git, tree-sitter-cli (já presente)
--
-- SAFE_REQUIRE (09/09/2026): pcall mudo trocado por
-- utils/safe_require.lua — ver nota completa em plugins/editing.lua.
-- Só no setup_kulala() — os require("kulala") dentro de cada atalho
-- <leader>h* continuam diretos, já protegidos pelo gate kulala_ready
-- (se o setup falhar, você já foi avisado antes de qualquer atalho
-- ser pressionado).
-- =========================================================

local safe_require = require("martini.utils.safe_require")

-- Ativa o filetype "http" para arquivos .http e .rest
vim.filetype.add({
  extension = {
    http = "http",
    rest = "http",
  },
})

-- PERF: o setup() do kulala só roda na primeira vez que um buffer
-- .http/.rest é aberto, ou um atalho <leader>h é usado — não no boot.
local kulala_ready = false

local function setup_kulala()
  if kulala_ready then return end
  kulala_ready = true

  safe_require("kulala", function(kulala)
    kulala.setup({
      -- Ambiente padrão (dev/test/prod definidos em http-client.env.json)
      default_env = "dev",

      ui = {
        display_mode = "split", -- resposta em um split
        split_direction = "right", -- abre à direita
        default_view = "body", -- mostra o corpo da resposta primeiro
      },

      -- Formatação da resposta JSON
      response_format = {
        indent = 2,
        expand_tabs = true,
        sort_keys = false,
      },

      -- Lê variáveis de ambiente no formato do REST Client (VSCode),
      -- mantendo compatibilidade com arquivos .http existentes
      vscode_rest_client_environmentvars = true,
    })
  end, "cliente HTTP (.http/.rest, <leader>h*)")
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "http",
  callback = function()
    vim.schedule(setup_kulala)
  end,
})

-- =========================================================
-- Atalhos (prefixo <leader>h, domínio HTTP)
-- =========================================================
local map = vim.keymap.set

map("n", "<leader>hs", function()
  setup_kulala()
  require("kulala").run()
end, { desc = "HTTP: enviar requisição sob o cursor" })

map("n", "<leader>ha", function()
  setup_kulala()
  require("kulala").run_all()
end, { desc = "HTTP: enviar todas as requisições do arquivo" })

map("n", "<leader>hb", function()
  setup_kulala()
  require("kulala").scratchpad()
end, { desc = "HTTP: abrir scratchpad" })

map("n", "<leader>hc", function()
  setup_kulala()
  require("kulala").copy()
end, { desc = "HTTP: copiar requisição como comando curl" })

map("n", "<leader>hn", function()
  setup_kulala()
  require("kulala").jump_next()
end, { desc = "HTTP: próxima requisição" })

map("n", "<leader>hp", function()
  setup_kulala()
  require("kulala").jump_prev()
end, { desc = "HTTP: requisição anterior" })

map("n", "<leader>hq", function()
  setup_kulala()
  require("kulala").close()
end, { desc = "HTTP: fechar janela de resposta" })
