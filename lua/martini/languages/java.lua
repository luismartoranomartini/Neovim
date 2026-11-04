-- =========================================================
-- lua/martini/languages/java.lua
-- Tudo que é específico de Java, consolidado num único lugar
-- (mesmo padrão de languages/go.lua e languages/python.lua).
-- Interface deste módulo, consumida por outros arquivos:
--   M.runner_filetypes → lido por plugins/runner.lua (tbl_extend)
-- Tudo o resto (highlight, keymaps de teste) roda direto ao dar
-- require() neste módulo.
-- Fora daqui: LSP (jdtls) em plugins/lsp.lua, formatação
-- (google-java-format, estilo AOSP de 4 espaços) em
-- plugins/format.lua, parser em plugins/treesitter.lua.
-- Ferramentas: JDK 21 e maven (pacman), jdtls e google-java-format
-- (Mason: :MasonInstall jdtls google-java-format).
-- Debug de Java (java-debug-adapter via jdtls) ficou de fora por ora.
-- =========================================================

local M = {}

-- =========================================================
-- Highlight: formatação do printf/String.format do Java (%d, %s,
-- %.2f, %n, %,d...). Mecanismo compartilhado, ver
-- utils/printf_highlight.lua.
-- =========================================================
require("martini.utils.printf_highlight").register("java", "bBhHsScCdoxXeEfgGaAtTn%")

-- =========================================================
-- Runner: contribuição pra tabela de filetypes do code_runner.nvim.
-- "java Arquivo.java" compila e executa na hora (modo arquivo-fonte,
-- JDK 11+). Serve pra exercícios de um arquivo só; projeto Maven
-- usa os atalhos <leader>k abaixo.
-- =========================================================
M.runner_filetypes = {
  java = "cd $dir && java $fileName",
}

-- =========================================================
-- Testes (Maven + JUnit): atalhos sob o prefixo <leader>k
-- (<leader>j é do JavaScript). Precisam de um pom.xml na pasta do
-- projeto ou acima dela.
-- =========================================================
local function rodar_mvn(args)
  local raiz = vim.fs.root(0, { "pom.xml" })
  if not raiz then
    vim.notify("pom.xml não encontrado: este atalho precisa de um projeto Maven", vim.log.levels.WARN)
    return
  end
  vim.cmd("botright new | resize 15")
  local cmd = { "mvn" }
  vim.list_extend(cmd, args)
  vim.fn.jobstart(cmd, { term = true, cwd = raiz })
end

-- <leader>kt : roda todos os testes do projeto
vim.keymap.set("n", "<leader>kt", function()
  rodar_mvn({ "test" })
end, { desc = "Java: testar projeto inteiro (mvn test)" })

-- <leader>kc : roda os testes da classe do arquivo atual
vim.keymap.set("n", "<leader>kc", function()
  local classe = vim.fn.expand("%:t:r")
  rodar_mvn({ "test", "-Dtest=" .. classe })
end, { desc = "Java: testar a classe do arquivo atual" })

-- <leader>km : roda APENAS o método de teste onde o cursor está (ou o
-- mais próximo acima). Procura "void nome(" subindo a partir do cursor.
vim.keymap.set("n", "<leader>km", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local metodo = nil

  for lnum = cursor_line, 1, -1 do
    local linha = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ""
    local nome = linha:match("void%s+([%w_]+)%s*%(")
    if nome then
      metodo = nome
      break
    end
  end

  if not metodo then
    vim.notify("Nenhum método de teste encontrado acima do cursor", vim.log.levels.WARN)
    return
  end

  local classe = vim.fn.expand("%:t:r")
  rodar_mvn({ "test", "-Dtest=" .. classe .. "#" .. metodo })
end, { desc = "Java: testar apenas o método sob o cursor" })

-- <leader>kb : compila o projeto
vim.keymap.set("n", "<leader>kb", function()
  rodar_mvn({ "compile" })
end, { desc = "Java: compilar projeto (mvn compile)" })

return M
