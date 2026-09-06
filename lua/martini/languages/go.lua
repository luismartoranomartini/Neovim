-- =========================================================
-- lua/martini/languages/go.lua
-- Tudo que é específico de Go, consolidado num único lugar.
-- Interface deste módulo, consumida por outros arquivos:
--   M.runner_filetypes → lido por plugins/runner.lua (tbl_extend)
--   M.setup_debug()    → chamado por plugins/debug.lua dentro do
--                         setup() lazy do debugger
-- Tudo o resto (filetype.add, highlights, lint, imports, keymaps de
-- teste) roda direto ao dar require() neste módulo — não precisa de
-- chamada explícita.
-- =========================================================

local M = {}

-- =========================================================
-- Filetype: reconhece arquivos .tmpl/.gohtml (Go HTML templates).
-- Tratados como "html" para ativar auto-fechamento de tags,
-- Emmet e o LSP de HTML sem depender de parser extra.
-- =========================================================
vim.filetype.add({
  extension = {
    tmpl = "html",
    gohtml = "html",
  },
  pattern = {
    -- pega nomes compostos como home.page.tmpl, layout.base.tmpl, etc.
    [".*%.tmpl"] = "html",
  },
})

-- Garante o filetype mesmo em casos que escapem das regras acima
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.tmpl",
  callback = function()
    vim.bo.filetype = "html"
  end,
})

-- =========================================================
-- Highlight: verbos de formatação do Go (%s, %d, %v, %+v, %-10.2f,
-- etc.) — mecanismo compartilhado, ver utils/printf_highlight.lua.
-- Conjunto de verbos do Go: v T t b c d o O q x X U e E f F g G s p %
-- (fmt package — https://pkg.go.dev/fmt)
-- =========================================================
require("martini.utils.printf_highlight").register("go", "vTtbcdoOqxXUeEfFgGsp%")

-- =========================================================
-- Highlight: destaque aproximado dos blocos {{ ... }} de template Go
-- dentro de arquivos HTML — via matchadd (não há parser Treesitter
-- funcional pra essa sintaxe). Não dá autocomplete — só contraste
-- visual. Mesmo caveat: matchadd() é por janela.
-- =========================================================
local function destacar_template_go()
  if vim.bo.filetype ~= "html" then return end
  if vim.w.martini_go_tmpl_hl then return end
  vim.fn.matchadd("GoTemplateAction", [=[{?_.{-?}}]=])
  vim.w.martini_go_tmpl_hl = true
end

vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter" }, {
  callback = destacar_template_go,
})

-- =========================================================
-- Lint: golangci-lint via nvim-lint
-- =========================================================
pcall(function()
  local lint = require("lint")

  if vim.fn.exepath("golangci-lint") == "" then
    vim.notify("golangci-lint não encontrado no PATH", vim.log.levels.WARN)
    return
  end

  -- Usa o linter "golangcilint" já embutido no nvim-lint — ele mesmo
  -- detecta a versão instalada (v1 ou v2) e escolhe cmd/args/parser
  -- corretos sozinho. NÃO sobrescrever isso aqui: uma versão anterior
  -- desta config fixava a flag "--output.json.path=stdout" (só existe
  -- na v2), e em ambiente com v1 instalada isso quebrava o parser
  -- (erro "Parser failed" ao tentar decodificar saída que não é JSON).
  lint.linters_by_ft = lint.linters_by_ft or {}
  lint.linters_by_ft.go = { "golangcilint" }

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = "*.go",
    callback = function() lint.try_lint() end,
  })
end)

-- =========================================================
-- Format: organiza imports do Go automaticamente ao salvar (remove
-- imports não usados e adiciona os que faltam), via code action do
-- gopls. Isso NÃO é feito pelo lsp_format do conform.nvim (ver
-- plugins/format.lua) — "organizar imports" é uma code action LSP
-- separada (source.organizeImports) que precisa ser pedida
-- explicitamente. Roda em BufWritePre, síncrono, ANTES do conform
-- formatar/salvar, para que o resultado já saia formatado corretamente.
-- =========================================================
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }

    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
    for _, res in pairs(result or {}) do
      for _, action in pairs(res.result or {}) do
        if action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
        elseif action.command then
          vim.lsp.buf.execute_command(action.command)
        end
      end
    end
  end,
})

-- =========================================================
-- Runner: contribuição pra tabela de filetypes do code_runner.nvim.
-- Lido por plugins/runner.lua via vim.tbl_extend.
-- =========================================================
M.runner_filetypes = {
  -- Go: roda o pacote inteiro da pasta
  go = "cd $dir && go run .",
}

-- =========================================================
-- Testes: atalhos sob o prefixo <leader>g (reservado pra Go).
-- =========================================================

-- <leader>gt : testa o pacote do arquivo atual (verbose)
vim.keymap.set("n", "<leader>gt", function()
  local dir = vim.fn.expand("%:p:h")
  vim.cmd("botright split | resize 15 | terminal cd " .. vim.fn.fnameescape(dir) .. " && go test -v")
end, { desc = "Go: testar pacote atual" })

-- <leader>ga : testa o projeto inteiro ("a" de "all")
vim.keymap.set("n", "<leader>ga", function()
  vim.cmd("botright split | resize 15 | terminal go test ./...")
end, { desc = "Go: testar projeto inteiro" })

-- <leader>gr : testa APENAS a função de teste onde o cursor está
-- posicionado (ou a função de teste mais próxima acima do cursor).
-- Usa go test -run ^NomeDaFuncao$ para escopar a um único teste.
-- IMPORTANTE: o padrão de Lua %w NÃO inclui sublinhado. Nomes de teste em Go
-- costumam usar underscore (ex.: Test_Create_Campaign), então o padrão de
-- casamento precisa ser [%w_]* — nunca %w* sozinho, ou o nome é cortado
-- no primeiro underscore.
vim.keymap.set("n", "<leader>gr", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local func_name = nil

  -- Varre da linha do cursor para cima até achar "func TestAlgo(t *testing.T)"
  for lnum = cursor_line, 1, -1 do
    local linha = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ""
    local nome = linha:match("^func%s+(Test[%w_]*)%s*%(")
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
  local cmd = string.format(
    "cd %s && go test -v -run ^%s$",
    vim.fn.fnameescape(dir),
    func_name
  )
  vim.cmd("botright split | resize 15 | terminal " .. cmd)
end, { desc = "Go: testar apenas a função de teste sob o cursor" })

-- =========================================================
-- Debug: dap-go. Chamado por plugins/debug.lua dentro do setup()
-- lazy do debugger (não roda sozinho ao dar require neste módulo).
-- =========================================================
function M.setup_debug()
  require("dap-go").setup({
    delve = {
      path = vim.fn.exepath("dlv"),
    },
  })
end

return M
