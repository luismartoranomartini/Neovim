-- =========================================================
-- lua/martini/languages/python.lua
-- Tudo que é específico de Python, consolidado num único lugar
-- (mesmo padrão de languages/go.lua).
-- Interface deste módulo, consumida por outros arquivos:
--   M.runner_filetypes → lido por plugins/runner.lua (tbl_extend)
--   M.setup_debug()    → chamado por plugins/debug.lua dentro do
--                         setup() lazy do debugger
-- Tudo o resto (highlight, lint, keymaps de teste) roda direto ao
-- dar require() neste módulo.
-- Fora daqui: LSP (pyright) em plugins/lsp.lua, formatação (ruff)
-- em plugins/format.lua, parser em plugins/treesitter.lua.
-- Ferramentas (Arch): pyright, ruff, python-pytest, python-debugpy.
-- =========================================================

local M = {}

-- =========================================================
-- Highlight: formatação "%" do Python ("%s", "%d", "%.2f", "%r"...).
-- Mecanismo compartilhado, ver utils/printf_highlight.lua.
-- =========================================================
require("martini.utils.printf_highlight").register("python", "diouxXeEfFgGcrsa%")

-- =========================================================
-- Lint: ruff via nvim-lint (roda ao salvar)
-- =========================================================
pcall(function()
  local lint = require("lint")

  if vim.fn.exepath("ruff") == "" then
    vim.notify("ruff não encontrado no PATH", vim.log.levels.WARN)
    return
  end

  lint.linters_by_ft = lint.linters_by_ft or {}
  lint.linters_by_ft.python = { "ruff" }

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = "*.py",
    callback = function()
      lint.try_lint()
    end,
  })
end)

-- =========================================================
-- Runner: contribuição pra tabela de filetypes do code_runner.nvim.
-- Lido por plugins/runner.lua via vim.tbl_extend.
-- -u: saída sem buffer (print aparece na hora no terminal).
-- =========================================================
M.runner_filetypes = {
  python = "cd $dir && python3 -u $fileName",
}

-- =========================================================
-- Testes: atalhos sob o prefixo <leader>p (reservado pra Python).
-- Usa "python3 -m pytest": põe a pasta atual no sys.path, então
-- "import modulo" funciona nos testes sem configuração extra.
-- =========================================================

-- <leader>pt : testa a pasta do arquivo atual (verbose)
vim.keymap.set("n", "<leader>pt", function()
  local dir = vim.fn.expand("%:p:h")
  vim.cmd("botright split | resize 15 | terminal cd " .. vim.fn.fnameescape(dir) .. " && python3 -m pytest -v")
end, { desc = "Python: testar pasta atual" })

-- <leader>pa : testa o projeto inteiro (a partir da pasta onde o Neovim abriu)
vim.keymap.set("n", "<leader>pa", function()
  vim.cmd("botright split | resize 15 | terminal python3 -m pytest -v")
end, { desc = "Python: testar projeto inteiro" })

-- <leader>pr : testa APENAS a função de teste sob o cursor (ou a mais
-- próxima acima). Procura "def test_algo(" e roda arquivo::função.
vim.keymap.set("n", "<leader>pr", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local func_name = nil

  for lnum = cursor_line, 1, -1 do
    local linha = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ""
    local nome = linha:match("^%s*def%s+(test[%w_]*)%s*%(")
    if nome then
      func_name = nome
      break
    end
  end

  if not func_name then
    vim.notify("Nenhuma função de teste encontrada acima do cursor", vim.log.levels.WARN)
    return
  end

  local dir = vim.fn.expand("%:p:h")
  local arquivo = vim.fn.expand("%:t")
  local cmd = string.format(
    "cd %s && python3 -m pytest -v %s::%s",
    vim.fn.fnameescape(dir),
    vim.fn.shellescape(arquivo),
    func_name
  )
  vim.cmd("botright split | resize 15 | terminal " .. cmd)
end, { desc = "Python: testar apenas a função sob o cursor" })

-- =========================================================
-- Debug: debugpy (pacote python-debugpy) direto no nvim-dap, sem
-- plugin extra. Chamado por plugins/debug.lua dentro do setup() lazy.
-- Usa o Python do .venv do projeto, se existir; senão o python3 do
-- sistema.
-- =========================================================
function M.setup_debug()
  local safe_require = require("martini.utils.safe_require")
  safe_require("dap", function(dap)
    dap.adapters.python = {
      type = "executable",
      command = "python3",
      args = { "-m", "debugpy.adapter" },
    }

    dap.configurations.python = {
      {
        type = "python",
        request = "launch",
        name = "Debug do arquivo atual",
        program = "${file}",
        cwd = "${fileDirname}",
        console = "integratedTerminal",
        pythonPath = function()
          local venv = vim.fn.getcwd() .. "/.venv/bin/python"
          if vim.fn.executable(venv) == 1 then
            return venv
          end
          return "python3"
        end,
      },
    }
  end, "debug de Python (F5/breakpoints em arquivos .py)")
end

return M
