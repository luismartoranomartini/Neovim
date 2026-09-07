-- =========================================================
-- lua/martini/plugins/runner.lua
-- Execução de arquivos via code_runner (<leader>r)
-- Variáveis reconhecidas pelo plugin nos comandos abaixo:
--   $fileName          → nome do arquivo com extensão
--   $fileNameWithoutExt → nome do arquivo sem extensão
--   $dir                → diretório do arquivo (sempre "cd $dir"
--                          antes de comandos que dependem de caminho
--                          relativo — caminho absoluto direto falha)
-- Os atalhos de teste do Go (<leader>gt/<leader>ga/<leader>gr) e a
-- entrada "go" desta tabela de filetypes são contribuídos por
-- languages/go.lua — este arquivo só monta a base genérica e mescla
-- o que cada languages/*.lua contribuir.
--
-- ESCOPO REDUZIDO (set/2026) ao que é usado: JS/TS, C/C++, HTML
-- (abrir no navegador), Lua (testar trechos da própria config).
-- Removidos: python, ruby, php, perl, rust, java, sh/bash.
--
-- CORREÇÃO (07/09/2026): "html" chamava xdg-open direto, sem
-- verificar o SO. xdg-open é Linux/BSD (freedesktop.org) — em
-- Windows o comando não existe (falha com "'xdg-open' não é
-- reconhecido..."), e o README declara Windows 11 como plataforma
-- suportada. Resolvido com vim.fn.has() detectando o SO em tempo de
-- carregamento e escolhendo o comando certo — mesma lógica que
-- languages/go.lua e config/keymaps.lua já usam pra outras diferenças
-- de plataforma (ver flag is_windows mencionada no restante da config).
-- =========================================================

-- Comando de abrir URL/arquivo no programa padrão do SO.
-- macOS: "open" · Windows: "start" (via cmd, precisa do "" — primeiro
-- argumento de start é o título da janela, senão o path com espaço
-- vira o título) · Linux/BSD (fallback): "xdg-open".
local open_cmd
if vim.fn.has("win32") == 1 then
  open_cmd = "cmd.exe /c start \"\""
elseif vim.fn.has("mac") == 1 then
  open_cmd = "open"
else
  open_cmd = "xdg-open"
end

local base_filetypes = {
  -- Interpretadas (rodam direto)
  lua = "lua",
  javascript = "node",
  typescript = "npx tsx",

  -- Compiladas: compilam em binário temporário e executam.
  -- -g inclui símbolos de debug no binário — sem isso, o codelldb
  -- roda o processo mas não consegue mapear endereço de memória
  -- para linha de código, e os breakpoints não param em lugar
  -- nenhum (ver plugins/debug.lua). Não afeta a execução normal.
  c = "cd $dir && gcc -g $fileName -o /tmp/$fileNameWithoutExt && /tmp/$fileNameWithoutExt",
  cpp = "cd $dir && g++ -g $fileName -o /tmp/$fileNameWithoutExt && /tmp/$fileNameWithoutExt",

  -- Abre no navegador padrão do sistema (comando resolvido acima
  -- conforme o SO — ver nota de correção no topo do arquivo).
  html = open_cmd .. " $dir/$fileName",
}

local go = require("martini.languages.go")
local filetypes = vim.tbl_extend("force", base_filetypes, go.runner_filetypes or {})

pcall(function()
  require("code_runner").setup({
    mode = "term",
    focus = true,
    startinsert = false,
    term = {
      position = "bot", -- terminal na parte inferior
      size = 12,
    },
    filetype = filetypes,
  })
end)
