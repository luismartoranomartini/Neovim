-- =========================================================
-- lua/martini/plugins/debug.lua
-- Debugger via nvim-dap, dap-ui e codelldb (C/C++).
-- dap-go (Go) fica em languages/go.lua, chamado a partir do setup()
-- abaixo, pra continuar fazendo parte do MESMO carregamento preguiçoso.
-- Configuração ADIADA (lazy): dapui/dap-go/codelldb só carregam na
-- PRIMEIRA ação de debug real (F5, breakpoint, etc.), não no boot.
-- config/keymaps.lua chama require("martini.plugins.debug").setup()
-- antes de qualquer comando do dap — por isso este módulo PRECISA
-- retornar uma tabela com setup, e não rodar tudo direto no topo
-- do arquivo (um module sem return vira true ao dar require, e
-- chamar .setup() nesse true gera "attempt to index a boolean
-- value").
--
-- ESCOPO REDUZIDO (set/2026): dap-python removido — Python fora do
-- escopo atual. Go + C/C++.
-- =========================================================

local configurado = false

local function setup()
  if configurado then return end
  configurado = true

  local ok_dap, dap = pcall(require, "dap")
  if not ok_dap then
    vim.notify("nvim-dap não encontrado", vim.log.levels.WARN)
    return
  end

  local ok_dapui, dapui = pcall(require, "dapui")
  if not ok_dapui then
    vim.notify("dap-ui não encontrado", vim.log.levels.WARN)
    return
  end

  -- Signs da coluna de sinais (sem isso, o Neovim usa um placeholder
  -- genérico — geralmente a letra do nome do sign — no lugar do ícone).
  vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpointHl", linehl = "", numhl = "" })
  vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointConditionHl", linehl = "", numhl = "" })
  vim.fn.sign_define("DapLogPoint", { text = "◈", texthl = "DapLogPointHl", linehl = "", numhl = "" })
  vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStoppedHl", linehl = "DapStoppedLine", numhl = "" })
  vim.fn.sign_define("DapBreakpointRejected", { text = "✕", texthl = "DapBreakpointRejectedHl", linehl = "", numhl = "" })

  dapui.setup()

  -- Go: ver languages/go.lua — safe_require do dap-go já fica lá
  -- dentro (ver nota "SAFE_REQUIRE" em setup_debug()), não precisa
  -- de proteção duplicada aqui.
  require("martini.languages.go").setup_debug()

  -- C/C++: codelldb (binário único — instalado via AUR:
  -- yay -S codelldb-bin — NÃO é um plugin Lua, então não entra no
  -- loader.lua). Sem o binário no PATH, só avisa e segue sem quebrar
  -- o resto do debug (Go continua funcionando).
  local codelldb_path = vim.fn.exepath("codelldb")
  if codelldb_path ~= "" then
    dap.adapters.codelldb = {
      type = "server",
      port = "${port}",
      executable = {
        command = codelldb_path,
        args = { "--port", "${port}" },
      },
    }

    -- Caminho padrão do binário sugerido bate com plugins/runner.lua:
    -- gcc/g++ compilam pra /tmp/<nome sem extensão> — só editável no
    -- prompt se o binário estiver em outro lugar.
    local function config_c()
      return {
        {
          name = "Debug (codelldb)",
          type = "codelldb",
          request = "launch",
          program = function()
            local sugestao = "/tmp/" .. vim.fn.expand("%:t:r")
            return vim.fn.input("Caminho do binário compilado: ", sugestao, "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
      }
    end

    dap.configurations.c = config_c()
    dap.configurations.cpp = config_c()
  else
    vim.notify(
      "codelldb não encontrado — debug de C/C++ desativado. Instale com: yay -S codelldb-bin",
      vim.log.levels.WARN
    )
  end

  -- Abre a interface visual automaticamente ao iniciar o debug
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  -- Fecha a interface visual automaticamente ao encerrar a sessão de
  -- debug (por qualquer um dos três eventos: terminated, exited, ou
  -- terminate manual).
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end
end

return { setup = setup }
