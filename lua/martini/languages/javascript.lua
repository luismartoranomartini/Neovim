-- =========================================================
-- lua/martini/languages/javascript.lua  (08/10/2026)
-- Tudo que é específico de JavaScript, no mesmo molde de go.lua.
-- JÁ coberto em outros arquivos (não repetir aqui):
--   LSP        → plugins/lsp.lua (ts_ls)
--   Treesitter → plugins/treesitter.lua
--   Formatação → plugins/format.lua (conform/prettier)
--   Executar   → plugins/runner.lua (javascript = "node", <leader>r)
-- Este módulo acrescenta TESTES, usando o test runner NATIVO do Node
-- (`node --test`, módulo node:test) — zero plugin, zero dependência.
--
-- Prefixo <leader>j (livre na gramática atual). Atalhos locais ao
-- buffer, só em arquivos JS/TS.
--
-- ATENÇÃO: --test-name-pattern exige Node >= 18.11 (confira: node -v).
-- Se o curso usar Jest/Vitest (npm test), <leader>ja já cobre: usa
-- `npm test` quando existe package.json com script "test".
-- =========================================================

local M = {}

-- Verbos do console.log / util.format do Node: %s %d %i %f %j %o %O %c %%
-- (nodejs.org/api/util.html#utilformatformat-args). Mecanismo
-- compartilhado em utils/printf_highlight.lua. Registrado uma vez por
-- filetype porque cada um tem a sua flag de janela.
for _, ft in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
  require("martini.utils.printf_highlight").register(ft, "sdifjoOc%")
end

local function terminal(cmd)
  vim.cmd("botright split | resize 15 | terminal " .. cmd)
end

local function dir_atual()
  return vim.fn.fnameescape(vim.fn.expand("%:p:h"))
end

-- Sobe a partir da pasta do arquivo até achar package.json.
local function raiz_projeto()
  local achado = vim.fs.find("package.json", { upward = true, path = vim.fn.expand("%:p:h") })[1]
  return achado and vim.fs.dirname(achado) or nil
end

local function tem_script_test(raiz)
  local f = io.open(raiz .. "/package.json", "r")
  if not f then
    return false
  end
  local conteudo = f:read("*a")
  f:close()
  local ok, pkg = pcall(vim.json.decode, conteudo)
  return ok and type(pkg) == "table" and type(pkg.scripts) == "table" and pkg.scripts.test ~= nil
end

local function mapear(bufnr)
  local function map(lhs, fn, desc)
    vim.keymap.set("n", lhs, fn, { buffer = bufnr, desc = desc })
  end

  -- <leader>jt : testa o arquivo atual (node --test <arquivo>)
  map("<leader>jt", function()
    terminal("cd " .. dir_atual() .. " && node --test " .. vim.fn.shellescape(vim.fn.expand("%:t")))
  end, "JS: testar arquivo atual")

  -- <leader>ja : testa o projeto inteiro. `npm test` se houver script
  -- "test" no package.json; senão `node --test` (acha *.test.js sozinho).
  map("<leader>ja", function()
    local raiz = raiz_projeto()
    if raiz and tem_script_test(raiz) then
      terminal("cd " .. vim.fn.fnameescape(raiz) .. " && npm test")
    else
      terminal("cd " .. (raiz and vim.fn.fnameescape(raiz) or dir_atual()) .. " && node --test")
    end
  end, "JS: testar projeto inteiro")

  -- <leader>jr : testa só o teste sob o cursor. Procura para cima uma
  -- linha como test("nome", ...) / it('nome', ...) / describe("nome", ...)
  -- e usa o texto entre aspas em --test-name-pattern.
  map("<leader>jr", function()
    local linha_cursor = vim.api.nvim_win_get_cursor(0)[1]
    local nome
    for lnum = linha_cursor, 1, -1 do
      local linha = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ""
      nome = linha:match("^%s*test%s*%(%s*[\"'`](.-)[\"'`]")
        or linha:match("^%s*it%s*%(%s*[\"'`](.-)[\"'`]")
        or linha:match("^%s*describe%s*%(%s*[\"'`](.-)[\"'`]")
      if nome then
        break
      end
    end
    if not nome then
      vim.notify("Nenhum test()/it()/describe() acima do cursor", vim.log.levels.WARN)
      return
    end
    -- O padrão é uma regex: escapa metacaracteres do nome do teste.
    local padrao = nome:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?|\\/]", "\\%0")
    terminal(
      string.format(
        "cd %s && node --test --test-name-pattern=%s %s",
        dir_atual(),
        vim.fn.shellescape(padrao),
        vim.fn.shellescape(vim.fn.expand("%:t"))
      )
    )
  end, "JS: testar apenas o teste sob o cursor")

  -- <leader>jw : roda o arquivo e reexecuta a cada salvamento
  map("<leader>jw", function()
    terminal("cd " .. dir_atual() .. " && node --watch " .. vim.fn.shellescape(vim.fn.expand("%:t")))
  end, "JS: rodar em modo watch")

  -- <leader>jn : REPL do Node
  map("<leader>jn", function()
    terminal("node")
  end, "JS: abrir REPL do Node")
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  callback = function(args)
    mapear(args.buf)
  end,
})

return M
