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

No primeiro boot, o `lazy.nvim` se instala sozinho, baixa todos os plugins e o Neovim **fecha o carregamento nesse ponto** (avisa via `vim.notify` e não chega a carregar `config`/`plugins`). Espere a janela de instalação terminar e reabra o Neovim — normal do primeiro boot, não é travamento.

Ao adicionar um plugin novo à lista existente (não é mais "primeiro boot"), a instalação roda em background de forma assíncrona; se algum `require` de plugin novo falhar com `module not found` logo depois de editar `lazy.lua`, rode `:Lazy` → `I` (install) e reabra o Neovim — é o clone ainda não ter terminado a tempo do boot.

## Estrutura

```
lua/martini/
├── init.lua              -- patch 0.12.2 + bootstrap + ordem de carregamento
├── lazy.lua              -- lista de plugins + comando :MartiniUpdate
├── config/
│   ├── init.lua          -- agregador
│   ├── options.lua       -- vim.opt/vim.g
│   ├── diagnostics.lua   -- vim.diagnostic.config()
│   ├── colors.lua        -- tokyonight + highlights customizados (toda cor da UI mora aqui)
│   ├── tabline.lua       -- tabline nativa customizada (lista buffers, sem plugin)
│   └── keymaps.lua       -- atalhos globais
├── languages/
│   ├── init.lua
│   ├── go.lua            -- highlight, lint, imports, testes, dap-go
│   └── c.lua             -- highlight de verbos printf/scanf
├── plugins/
│   ├── init.lua
│   ├── treesitter.lua, textobjects.lua
│   ├── completion.lua, lsp.lua, format.lua
│   ├── debug.lua, runner.lua
│   ├── editing.lua, finder.lua, multicursor.lua, http.lua
│   ├── oil.lua           -- explorador de arquivos (edita o filesystem como buffer)
│   ├── otter.lua         -- autocomplete de JS/CSS embutido em HTML
│   └── dashboard.lua     -- tela inicial (snacks.nvim)
└── utils/
    ├── path.lua               -- gf, criação de arquivo
    ├── terminal.lua           -- abrir/toggle terminal
    └── printf_highlight.lua   -- destaque de verbos %s/%d (Go, C)
```

## Plugins

| Plugin | Função |
|---|---|
| tokyonight.nvim | tema base |
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
| otter.nvim | LSP embutido (JS/CSS dentro de HTML) |
| oil.nvim | explorador de arquivos — edita o filesystem como texto |
| mini.icons | provedor de ícone (oil, fzf-lua) |

Sem `bufferline.nvim` de propósito: as abas visíveis no topo são a tabline nativa do Neovim, renderizada por `config/tabline.lua` (lista buffers abertos), sem dependência externa.

## LSP

| Servidor | Filetypes | Formatação |
|---|---|---|
| gopls | go, gomod, gowork | gofmt (fallback) + organizeImports automático |
| ts_ls | javascript, typescript, typescriptreact | prettier |
| html | html, gotmpl (templates Go) | prettier |
| cssls | css, scss, less | prettier |
| clangd | c, cpp, objc, objcpp | clang-format |

## Atalhos

`<leader>` = `Espaço`. Gramática: `<leader>` + domínio + verbo — `b` buffers, `f` find/arquivo, `g` Go, `m` multicursor, `d` debug, `r` run, `h` HTTP. Fora da gramática, por convenção do ecossistema: `gd`/`K`/`[d`/`]d` (LSP), `]b`/`[b` (buffers), `]f`/`[f`/`]c`/`[c` (textobjects), `gf`.

⚠️ Não confundir: `<leader>bd` (buffer → fechar) × `<leader>db` (debug → breakpoint).

**Arquivos:** `<leader>e` explorador (oil, substitui o buffer) · `<leader>fe` explorador em split vertical · `gf` abrir/criar arquivo sob o cursor · `<leader>fn` novo arquivo · `<leader>fd` reabrir dashboard · `<leader>n`/`<leader>w` nova/fechar tabpage · `<C-p>` buscar arquivo · `<C-g>` buscar texto

**Buffers:** `<leader>bd` fechar · `<leader>bx` fechar forçado · `]b`/`[b` próximo/anterior — a tabline no topo lista os buffers abertos; clique esquerdo troca, clique do meio fecha

**LSP:** `gd` definição · `K` hover · `[d`/`]d` diagnóstico anterior/próximo · `<leader>fr` rename · `<leader>fu` references

**Textobjects:** `af`/`if` função · `ac`/`ic` struct/class · `aa`/`ia` parâmetro · `]f`/`[f` e `]c`/`[c` navegação sem selecionar

**Go:** `<leader>gt` testar pacote · `<leader>ga` testar tudo · `<leader>gr` testar função sob o cursor

**Debug:** `<F5>`/`<F10>`/`<F11>`/`<F12>` ou `<leader>d{b,x,c,o,i,k,r,t,u}` (breakpoint, limpar, continue, step over/into/out, REPL, terminar, UI)

**Multicursor:** `<C-Up>`/`<C-Down>` cursor acima/abaixo · `<leader>mn`/`mp` próxima/anterior ocorrência · `<leader>ma` todas · `<leader>mx` remover · `<Esc>` sair

**HTTP** (arquivos `.http`/`.rest`): `<leader>hs` enviar · `<leader>ha` enviar todas · `<leader>hb` scratchpad · `<leader>hc` copiar como curl · `<leader>hn`/`<leader>hp` próxima/anterior · `<leader>hq` fechar resposta

**Terminal:** `<leader>t` horizontal · `<leader>vs` vertical · `<C-t>` toggle

**Runner:** `<leader>r` executar arquivo · `<leader>rp` executar projeto

## Explorador de arquivos (oil.nvim)

Sem netrw: `oil.nvim` assume qualquer diretório aberto. Edita a listagem como texto normal — deletar linha deleta o arquivo, `yy`+`p` move, editar o texto renomeia, nada toca o disco até `:w` (que mostra um preview antes de aplicar). `g?` mostra os keymaps internos; `-` sobe um nível.

Pastas de sistema do NTFS (`$RECYCLE.BIN`, `System Volume Information`, `.Trash-<n>`) ficam sempre ocultas — abri-las derruba o oil com `assertion failed` em `vim.fs.abspath`, por falha de permissão em volumes Windows montados no Linux.

## Busca (fzf-lua)

Janela centralizada (60%×70% da tela), preview fixo à direita, cores integradas à paleta do `colors.lua`. Busca por **nome de arquivo** (`<C-p>`) ou **texto** (`<C-g>`) em todo o projeto a partir do diretório atual — não navega pastas (isso é papel do oil). Pra buscar a partir de outra pasta, navegue até lá pelo oil primeiro.

## Dashboard

Tela inicial via `snacks.nvim`: banner, menu, arquivos recentes, git status (cacheado 5 min) e tempo de boot. Reabra a qualquer momento com `<leader>fd`.

## Atualização de plugins

Sem atualização automática em background — decisão explícita, pra não regravar o `lazy-lock.json` sozinho a cada boot. `:MartiniUpdate` abre a UI do `lazy.nvim` (`require("lazy").update()`) pra você revisar e confirmar. Só atualiza o que já está instalado; pra instalar plugins novos recém-adicionados à lista, use `:Lazy` → `I`.
