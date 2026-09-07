-- =========================================================
-- lua/martini/plugins/lsp.lua
-- Servidores LSP (Neovim 0.12 API nativa — sem nvim-lspconfig) e
-- keymaps ativados em LspAttach.
-- completion.lua carrega ANTES deste arquivo e define
-- vim.lsp.config["*"].capabilities — os servidores abaixo herdam isso.
--
-- ESCOPO REDUZIDO (set/2026): gopls (Go), ts_ls (JS/TS), html/cssls
-- (web + templates Go), clangd (C). pyright removido — Python fora
-- do escopo atual.
--
-- CORREÇÃO (07/09/2026): [d/]d usavam vim.diagnostic.goto_prev/
-- goto_next diretamente. Ambos deprecados desde o Neovim 0.11 (ver
-- :help deprecated) em favor de vim.diagnostic.jump({count=...}) —
-- continuam funcionando, mas emitem aviso de depreciação na PRIMEIRA
-- vez que forem chamados na sessão (por isso não aparecia no
-- :checkhealth: a checagem de depreciação só flagra o que já foi
-- efetivamente executado, não o que está só mapeado). Trocado pela
-- API atual, com float=true pra manter o comportamento de abrir a
-- janela flutuante com a mensagem do diagnóstico (era o padrão
-- implícito de goto_prev/goto_next; o jump() novo não abre por
-- padrão, então precisa ser pedido explicitamente).
-- =========================================================

-- ── Keymaps LSP (ativados ao conectar) ───────────────────
-- gd/K/[d/]d DELIBERADAMENTE mantidos sem prefixo <leader> — convenção
-- universal do ecossistema Neovim (ver :h lsp-quickstart).
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, opts)
    vim.keymap.set("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, opts)
    vim.keymap.set("n", "<leader>fr", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>fu", vim.lsp.buf.references, opts)
  end,
})

-- ── Servidores LSP ───────────────────────────────────────
local function configurar_lsp(nome, executavel, filetypes, root_markers)
  local caminho = vim.fn.exepath(executavel)
  if caminho == "" then
    vim.notify("LSP não encontrado: " .. executavel, vim.log.levels.WARN)
    return
  end
  vim.lsp.config[nome] = {
    cmd = { caminho, "--stdio" },
    filetypes = filetypes,
    root_markers = root_markers,
  }
  vim.lsp.enable(nome)
end

-- gopls não aceita --stdio; usa stdio por padrão sem flags
do
  local caminho = vim.fn.exepath("gopls")
  if caminho ~= "" then
    vim.lsp.config["gopls"] = {
      cmd = { caminho },
      filetypes = { "go", "gomod", "gowork" },
      root_markers = { "go.mod", "go.work", ".git" },
      settings = {
        gopls = {
          analyses = { unusedparams = true },
          staticcheck = true,
          semanticTokens = true,
        },
      },
    }
    vim.lsp.enable("gopls")
  else
    vim.notify("LSP não encontrado: gopls", vim.log.levels.WARN)
  end
end

configurar_lsp("ts_ls", "typescript-language-server",
  { "javascript", "typescript", "typescriptreact" },
  { "package.json", "tsconfig.json", ".git" })

configurar_lsp("html", "vscode-html-language-server",
  { "html", "gotmpl" },
  { ".git" })

configurar_lsp("cssls", "vscode-css-language-server",
  { "css", "scss", "less" },
  { ".git" })

-- clangd: LSP de C/C++. Não usa --stdio (já é o padrão).
do
  local caminho = vim.fn.exepath("clangd")
  if caminho ~= "" then
    vim.lsp.config["clangd"] = {
      cmd = { caminho },
      filetypes = { "c", "cpp", "objc", "objcpp" },
      root_markers = { "compile_commands.json", "compile_flags.txt", ".git", "Makefile" },
    }
    vim.lsp.enable("clangd")
  else
    vim.notify("LSP não encontrado: clangd", vim.log.levels.WARN)
  end
end
