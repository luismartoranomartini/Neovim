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
--
-- TABOUT vs <Tab> NATIVO DE SNIPPET (26/09/2026): descoberto ao
-- depurar por que tabout.nvim (plugins/tabout.lua) não pulava fora de
-- aspas/parênteses em NENHUM arquivo com LSP conectado (Go, TS, C):
-- o Neovim 0.11+ registra, neste MESMO evento LspAttach, um <Tab>
-- NATIVO e LOCAL AO BUFFER (vim.snippet.jump, ver vim._defaults do
-- próprio runtime). Mapeamento local ao buffer SEMPRE vence o global
-- do tabout, não importa em que ordem os plugins carregam — por isso
-- só funcionava depois de chamar require("tabout").setup() nA MÃO,
-- depois do LSP já ter conectado. Corrigido sobrescrevendo <Tab> pro
-- <Plug>(Tabout) aqui dentro, DEPOIS do autocmd nativo (autocmds do
-- mesmo evento rodam na ordem em que foram registrados — o nosso,
-- definido durante o carregamento dos plugins, roda depois do
-- embutido no runtime). EXCLUI os filetypes de Emmet: completion.lua
-- já define um <Tab> local ao buffer pra eles (cmp → Emmet) e
-- QUEREMOS que esse vença ali, não o tabout — html/cssls também
-- passam por este LspAttach, então a checagem de filetype é
-- necessária pra não quebrar o Emmet.
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

    -- Ver nota "TABOUT vs <Tab> NATIVO DE SNIPPET" no topo do arquivo.
    local emmet_filetypes = { html = true, css = true, scss = true, jsx = true, tsx = true }
    if not emmet_filetypes[vim.bo[args.buf].filetype] then
      vim.keymap.set("i", "<Tab>", "<Plug>(Tabout)", opts)
    end
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

-- htmx-lsp (09/09/2026): autocomplete de atributos hx-* em HTML e
-- templates Go. ATENÇÃO — diferente dos outros LSPs acima, esse é
-- melhor esforço, não confirmado: o próprio projeto
-- (rajasegar/htmx-lsp) marca só o Helix como testado, Neovim fica
-- desmarcado no checklist do README, e não existe exemplo oficial de
-- config pra nenhum dos dois. O --stdio é inferido pela convenção da
-- lib que ele usa por baixo (vscode-languageserver — mesma base do
-- html/cssls acima), não confirmado no README do htmx-lsp em si. Se
-- não conectar, `:LspLog` é o primeiro lugar pra olhar.
configurar_lsp("htmx", "htmx-lsp",
  { "html", "gotmpl" },
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
