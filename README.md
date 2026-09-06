# martini.nvim

Configuração pessoal do Neovim, focada em Go, JavaScript/TypeScript (web) e C. Sem plugin manager hand-rolled — gerenciado via [lazy.nvim](https://github.com/folke/lazy.nvim).

## Requisitos

- Neovim 0.12+
- `git`
- LSP: `gopls`, `typescript-language-server`, `vscode-html-language-server`, `vscode-css-language-server`, `clangd`
- Lint/format: `golangci-lint` (v1 ou v2), `prettier`, `clang-format`
- Debug: `dlv` (Delve, Go), `codelldb` (C/C++)
- Runner/busca: `fd`, `fzf`, `ripgrep` (`rg`), `bat` (preview)
- `xdg-open` (abrir HTML no navegador via runner)

## Instalação

```bash
git clone https://github.com/luismartoranomartini/Neovim.git ~/.config/nvim
nvim
```

No primeiro boot, o `lazy.nvim` se instala sozinho e baixa todos os plugins. Aguarde a janela terminar e reinicie o Neovim.

## Estrutura
lua/martini/
├── init.lua -- patch 0.12.2 + bootstrap + ordem de carregamento
├── lazy.lua -- lista de plugins + atualização automática
├── config/
│ ├── init.lua -- agregador
│ ├── options.lua -- vim.opt/vim.g
│ ├── diagnostics.lua -- vim.diagnostic.config()
│ ├── colors.lua -- tokyonight + highlights customizados
│ └── keymaps.lua -- atalhos globais
├── languages/
│ ├── init.lua
│ ├── go.lua -- highlight, lint, imports, testes, dap-go
│ └── c.lua -- highlight de verbos printf/scanf
├── plugins/
│ ├── init.lua
│ ├── treesitter.lua, textobjects.lua
│ ├── completion.lua, lsp.lua, format.lua
│ ├── debug.lua, runner.lua
│ ├── editing.lua, finder.lua, multicursor.lua, http.lua
│ └── dashboard.lua -- tela inicial (snacks.nvim)
└── utils/
├── path.lua -- gf, criação de arquivo
├── terminal.lua -- abrir/toggle terminal
└── printf_highlight.lua -- destaque de verbos %s/%d (Go, C)

## Plugins

| Plugin | Função |
|---|---|
| tokyonight.nvim | tema |
| snacks.nvim | dashboard (só esse módulo é usado) |
| nvim-treesitter (+ textobjects) | highlight + seleção por função/struct/parâmetro |
| nvim-cmp, cmp-nvim-lsp, cmp-buffer, LuaSnip, cmp_luasnip, friendly-snippets | autocomplete |
| nvim-autopairs, nvim-ts-autotag, nvim-surround, emmet-vim | edição (fecha par, tag JSX/HTML, delimitadores, abreviação) |
| conform.nvim | format on save |
| nvim-lint | golangci-lint |
| nvim-dap, nvim-dap-ui, nvim-nio, nvim-dap-go | debug (Go + C via codelldb) |
| code_runner.nvim | executa o arquivo atual |
| kulala.nvim | cliente HTTP (`.http`/`.rest`) |
| multicursor.nvim (branch `1.0`) | múltiplos cursores |
| fzf-lua | busca fuzzy de arquivo/texto, com preview |

## LSP

| Servidor | Filetypes | Formatação |
|---|---|---|
| gopls | go, gomod, gowork | gofmt (fallback) + organizeImports automático |
| ts_ls | javascript, typescript, typescriptreact | prettier |
| html | html, gotmpl (templates Go) | prettier |
| cssls | css, scss, less | prettier |
| clangd | c, cpp, objc, objcpp | clang-format |

## Atalhos

`<leader>` = `Espaço`. Gramática: `<leader>` + domínio + verbo — `b` buffers, `f` find/arquivo, `g` Go, `m` multicursor, `d` debug, `r` run, `h` HTTP.

**Arquivos:** `<leader>n` nova aba · `<leader>e` explorador (netrw) · `gf` abrir/criar arquivo sob o cursor · `<leader>fn` novo arquivo · `<leader>fd` reabrir dashboard · `<C-p>` buscar arquivo · `<C-g>` buscar texto

**LSP:** `gd` definição · `K` hover · `[d`/`]d` diagnóstico anterior/próximo · `<leader>fr` rename · `<leader>fu` references

**Go:** `<leader>gt` testar pacote · `<leader>ga` testar tudo · `<leader>gr` testar função sob o cursor

**Debug:** `<F5>`/`<F10>`/`<F11>`/`<F12>` ou `<leader>d{b,x,c,o,i,k,r,t,u}` (breakpoint, limpar, continue, step over/into/out, REPL, terminar, UI)

**Multicursor:** `<C-Up>`/`<C-Down>` cursor acima/abaixo · `<leader>mn`/`mp` próxima/anterior ocorrência · `<leader>ma` todas · `<leader>mx` remover · `<Esc>` sair

**HTTP:** `<leader>hs` enviar · `<leader>ha` enviar todas · `<leader>hb` scratchpad · `<leader>hc` copiar como curl

**Terminal:** `<leader>t` horizontal · `<leader>vs` vertical · `<C-t>` toggle

**Runner:** `<leader>r` executar arquivo · `<leader>rp` executar projeto

## Dashboard

Tela inicial via `snacks.nvim`: banner, menu, arquivos recentes, git status (cacheado) e tempo de boot. Reabra a qualquer momento com `<leader>fd`.

## Atualização automática

`lazy.lua` roda `require("lazy").update({ show = false })` ~1s após abrir o Neovim, em background — atualiza os plugins e regrava o `lazy-lock.json` sozinho. `:Lazy` continua disponível pra checar/instalar/limpar manualmente.
