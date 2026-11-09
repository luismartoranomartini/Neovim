-- =========================================================
-- lua/martini/languages/rust.lua
-- Tudo que é específico de Rust, consolidado num único lugar
-- (mesmo padrão de languages/go.lua, python.lua e java.lua).
-- Interface deste módulo, consumida por outros arquivos:
--   M.runner_filetypes → lido por plugins/runner.lua (tbl_extend)
--   M.setup_debug()    → chamado por plugins/debug.lua dentro do
--                        setup() lazy do debugger
-- Tudo o resto (highlight, keymaps de teste) roda direto ao dar
-- require() neste módulo.
-- Fora daqui: LSP (rust-analyzer, via rustup) em plugins/lsp.lua,
-- formatação (rustfmt) em plugins/format.lua, parser em
-- plugins/treesitter.lua.
-- Ferramentas (Arch): sudo pacman -S rustup, depois
--   rustup default stable
--   rustup component add rust-analyzer rustfmt clippy
-- Debug: usa o codelldb, o mesmo adaptador do C (plugins/debug.lua).
-- =========================================================

local M = {}

-- =========================================================
-- Highlight: marcadores de formato do Rust em println!/format!:
-- {}, {:?}, {:#?}, {nome}, {0}, {:>8.2}. Aproximado (matchadd não
-- sabe se está dentro de string): {{ e }} escapados não casam, mas
-- um bloco vazio {} fora de string pode ser colorido por engano.
-- Mesmo grupo PrintfVerb e mesma prioridade do utils/printf_highlight.
-- =========================================================
do
  local flag = "martini_fmt_hl_rust"
  local pattern = [=[\%({\)\@<!{\%([A-Za-z_][A-Za-z0-9_]*\|[0-9]\+\)\=\%(:[^{}"]*\)\=}]=]

  local function aplicar()
    if vim.bo.filetype ~= "rust" or vim.w[flag] then
      return
    end
    vim.fn.matchadd("PrintfVerb", pattern, 200)
    vim.w[flag] = true
  end

  vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter" }, {
    callback = aplicar,
  })
end

-- =========================================================
-- Runner: contribuição pra tabela de filetypes do code_runner.nvim.
-- Dentro de um projeto cargo (Cargo.toml na pasta ou acima): cargo
-- run. Arquivo solto: compila com rustc (-g = símbolos de debug, pro
-- codelldb) num binário temporário e executa.
-- =========================================================
M.runner_filetypes = {
  rust = "cd $dir && if cargo locate-project >/dev/null 2>&1; then cargo run; "
    .. "else rustc -g $fileName -o /tmp/$fileNameWithoutExt && /tmp/$fileNameWithoutExt; fi",
}

-- =========================================================
-- Cargo: atalhos sob o prefixo <leader>y (precisam de Cargo.toml
-- na pasta do projeto ou acima dela)
-- =========================================================
local function rodar_cargo(args)
  local raiz = vim.fs.root(0, { "Cargo.toml" })
  if not raiz then
    vim.notify("Cargo.toml não encontrado: este atalho precisa de um projeto cargo", vim.log.levels.WARN)
    return
  end
  vim.cmd("botright new | resize 15")
  local cmd = { "cargo" }
  vim.list_extend(cmd, args)
  vim.fn.jobstart(cmd, { term = true, cwd = raiz })
end

-- <leader>yt : roda todos os testes do projeto (mostra os println!)
vim.keymap.set("n", "<leader>yt", function()
  rodar_cargo({ "test", "--", "--nocapture" })
end, { desc = "Rust: testar projeto inteiro (cargo test)" })

-- <leader>yf : roda APENAS a função de teste onde o cursor está (ou a
-- mais próxima acima). Procura "fn nome(" subindo a partir do cursor.
vim.keymap.set("n", "<leader>yf", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local nome = nil

  for lnum = cursor_line, 1, -1 do
    local linha = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ""
    nome = linha:match("fn%s+([%w_]+)%s*[<(]")
    if nome then
      break
    end
  end

  if not nome then
    vim.notify("Nenhuma função encontrada acima do cursor", vim.log.levels.WARN)
    return
  end

  rodar_cargo({ "test", nome, "--", "--nocapture" })
end, { desc = "Rust: testar apenas a função sob o cursor" })

-- <leader>yb : compila o projeto
vim.keymap.set("n", "<leader>yb", function()
  rodar_cargo({ "build" })
end, { desc = "Rust: compilar projeto (cargo build)" })

-- <leader>yl : clippy, o linter oficial do Rust
vim.keymap.set("n", "<leader>yl", function()
  rodar_cargo({ "clippy" })
end, { desc = "Rust: linter (cargo clippy)" })

-- =========================================================
-- Debug (codelldb): reaproveita o adaptador "codelldb" que
-- plugins/debug.lua registra para C/C++. Em projeto cargo, compila
-- (cargo build) e sugere target/debug/<nome do pacote>; arquivo solto
-- sugere /tmp/<nome>, o mesmo binário que o runner acima gera.
-- =========================================================
function M.setup_debug()
  local safe_require = require("martini.utils.safe_require")
  safe_require("dap", function(dap)
    dap.configurations.rust = {
      {
        name = "Debug (codelldb)",
        type = "codelldb",
        request = "launch",
        program = function()
          local raiz = vim.fs.root(0, { "Cargo.toml" })
          local sugestao = "/tmp/" .. vim.fn.expand("%:t:r")
          if raiz then
            local saida = vim.fn.system({ "cargo", "build", "--manifest-path", raiz .. "/Cargo.toml" })
            if vim.v.shell_error ~= 0 then
              vim.notify("cargo build falhou:\n" .. saida, vim.log.levels.ERROR)
            end
            local f = io.open(raiz .. "/Cargo.toml")
            local conteudo = f and f:read("*a") or ""
            if f then
              f:close()
            end
            local nome = conteudo:match('name%s*=%s*"([^"]+)"')
            if nome then
              sugestao = raiz .. "/target/debug/" .. nome
            end
          end
          return vim.fn.input("Caminho do binário compilado: ", sugestao, "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = {},
      },
    }
  end, "debug de Rust (F5/breakpoints em arquivos .rs)")
end

return M
