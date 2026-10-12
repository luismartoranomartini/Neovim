# martini.nvim

Configuração pessoal do Neovim, focada em **Go**, **JavaScript/TypeScript (web)** e **C**. Gerenciada pelo [lazy.nvim](https://github.com/folke/lazy.nvim), escrita em Lua e organizada em módulos pequenos (um assunto por arquivo).

## Requisitos

- **Neovim 0.12+** (usa a API nativa `vim.lsp.config`/`vim.lsp.enable` e o `ui2`), `git`, `curl`
- Toolchain: `go` (compila `gopls`/`dlv`), `node` + `npm` (LSPs web, `prettier`, runner de `.ts`), `gcc`/`g++` (runner de `.c`/`.cpp`)
- LSP: `gopls`, `typescript-language-server`, `vscode-html-language-server`, `vscode-css-language-server`, `clangd`, `lua-language-server` (opcional: `htmx-lsp`, ver nota abaixo)
- Lint/format: `golangci-lint`, `prettier`, `clang-format`, `stylua`, `gofmt` (vem com o Go)
- Debug: `dlv` (Delve, Go), `codelldb` (C/C++)
- Busca: `fd`, `fzf`, `ripgrep` (`rg`), `bat` (preview)
- Testes: `go` (neotest-golang) e, opcionalmente, `gotestsum`; `node` 18.11+ para o `node --test` do módulo JavaScript
- `xdg-open` (abrir HTML no navegador via runner)
- `imagemagick` (renderizar imagens no buffer; backend kitty no WezTerm)

Rode `:checkhealth martini` depois de instalar tudo para conferir de uma vez o que falta.

Testado em **Arch Linux** e **Fedora**. Sem suporte a Windows documentado.

> **htmx-lsp** é melhor esforço: o próprio projeto (rajasegar/htmx-lsp) não marca o Neovim como testado. Se não conectar, `:LspLog` é o primeiro lugar para olhar.

## Instalação das dependências (Arch / Fedora)

| Ferramenta | Finalidade | Arch Linux | Fedora |
|---|---|---|---|
| `git`, `curl` | básico | `pacman -S git curl` | `dnf install git curl` |
| `go` | toolchain Go | `pacman -S go` | `dnf install golang` |
| `nodejs`, `npm` | toolchain JS | `pacman -S nodejs npm` | `dnf install nodejs` |
| `gcc`, `g++` | compilar `.c`/`.cpp` | `pacman -S gcc` | `dnf install gcc gcc-c++` |
| `gopls` | LSP Go | `go install golang.org/x/tools/gopls@latest` | idêntico |
| `typescript-language-server` | LSP JS/TS | `npm i -g typescript-language-server typescript` | idêntico |
| `vscode-html-language-server`, `vscode-css-language-server` | LSP HTML/CSS | `npm i -g vscode-langservers-extracted` | idêntico |
| `clangd`, `clang-format` | LSP C + formatação | `pacman -S clang` | `dnf install clang-tools-extra` |
| `golangci-lint` | lint Go | script oficial: `curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh \| sh -s -- -b $(go env GOPATH)/bin` | idêntico |
| `lua-language-server` | LSP Lua | `pacman -S lua-language-server` | `dnf install lua-language-server` |
| `stylua` | formatação Lua | `pacman -S stylua` | `cargo install stylua` |
| `prettier` | formatação JS/TS/HTML/CSS/JSON | `npm i -g prettier` | idêntico |
| `dlv` (Delve) | debug Go | `go install github.com/go-delve/delve/cmd/dlv@latest` | idêntico |
| `codelldb` | debug C/C++ | `yay -S codelldb-bin` (AUR) | baixe o `.vsix` da [release](https://github.com/vadimcn/codelldb/releases), extraia e coloque `extension/adapter/codelldb` no PATH |
| `fd`, `fzf`, `ripgrep`, `bat` | busca e preview | `pacman -S fd fzf ripgrep bat` | `dnf install fd-find fzf ripgrep bat` |
| `imagemagick` | imagens no buffer | `pacman -S imagemagick` | `dnf install ImageMagick` |
| `xdg-utils` | abrir HTML no navegador | `pacman -S xdg-utils` | `dnf install xdg-utils` |

As ferramentas do gopher.nvim (`gomodifytags`, `impl` e outras) são instaladas de dentro do Neovim com `:GoInstallDeps`. O `gotestsum` é instalado pelo `lazy.nvim` junto com o neotest-golang (`go install gotest.tools/gotestsum@latest`).

## Instalação

```bash
git clone https://github.com/luismartoranomartini/Neovim.git ~/.config/nvim
nvim
```

No primeiro boot o `lazy.nvim` se instala sozinho e baixa todos os plugins. O Neovim **interrompe o carregamento nesse ponto** (avisa via `vim.notify`). Espere a instalação terminar e reabra o Neovim — é normal do primeiro boot, não é travamento.

**Plugin novo adicionado ao `lazy.lua`:** rode `:Lazy sync` e **reinicie o Neovim**. A config só é lida na inicialização, e os atalhos de plugins carregados sob demanda só passam a existir depois disso.

## Estrutura

```
lua/martini/
├── init.lua              -- ui2 + bootstrap + ordem de carregamento
├── lazy.lua              -- lista de plugins + comando :MartiniUpdate
├── health.lua            -- :checkhealth martini
├── config/
│   ├── init.lua          -- agregador
│   ├── options.lua       -- vim.opt/vim.g
│   ├── diagnostics.lua   -- vim.diagnostic.config()
│   ├── colors.lua        -- tokyonight + highlights customizados (toda cor da UI mora aqui)
│   ├── tabline.lua       -- tabline nativa (lista buffers, sem plugin)
│   ├── keymaps.lua       -- atalhos globais
│   └── doc_keymaps.lua   -- :MartiniDocKeymaps (gera tabela de atalhos)
├── languages/            -- tudo específico de uma linguagem
│   ├── init.lua
│   ├── go.lua            -- filetypes, highlight, lint, imports, testes, dap-go
│   ├── javascript.lua    -- testes com node --test (<leader>j*)
│   └── c.lua             -- highlight de verbos printf/scanf
├── plugins/              -- um arquivo por plugin/assunto
│   ├── init.lua          -- ordem de carregamento (ver "Ordem de inicialização")
│   ├── treesitter.lua, textobjects.lua, mini-ai.lua
│   ├── completion.lua, lsp.lua, mason.lua, format.lua
│   ├── debug.lua, runner.lua, http.lua
│   ├── editing.lua, tabout.lua, multicursor.lua, flash.lua
│   ├── finder.lua, oil.lua, dashboard.lua
│   ├── gitsigns.lua, lualine.lua, tiny-cmdline.lua, tiny-inline-diagnostic.lua
│   ├── smart-splits.lua, live-server.lua
│   └── ...
└── utils/
    ├── path.lua               -- gf, criação de arquivo
    ├── terminal.lua           -- abrir/toggle terminal
    ├── safe_require.lua       -- require com aviso claro quando falta um plugin
    ├── printf_highlight.lua   -- destaque de verbos %s/%d (Go, C)
    └── type_highlight.lua     -- cor própria por tipo builtin (via Treesitter)
```

Os plugins pequenos ficam declarados direto no `lazy.lua` (`neotest`, `gopher.nvim`, `ccc.nvim`, `nvim-hlslens`), com o `config` no próprio spec.

### Ordem de inicialização

`plugins/init.lua` faz os `require` **em uma ordem que importa**:

- `treesitter` antes de `textobjects` (que depende dos parsers registrados).
- `mason` antes de `lsp`: o Mason coloca seus binários no `PATH`, e o `lsp.lua` procura os executáveis com `vim.fn.exepath()`.
- `completion` antes de `lsp`: define `vim.lsp.config["*"].capabilities`, que os servidores herdam.

Um `require` esquecido nessa lista já aconteceu mais de uma vez (o `setup()` do módulo simplesmente nunca rodava). Ao criar um módulo novo, **adicione o `require` em `plugins/init.lua`**.

## Plugins

| Plugin | Função |
|---|---|
| tokyonight.nvim | tema base |
| snacks.nvim | dashboard (só esse módulo é usado) |
| lualine.nvim | statusline (com aviso de arquivo não salvo) |
| nvim-treesitter (+ textobjects) | highlight + seleção por função/struct/parâmetro |
| blink.cmp, LuaSnip, friendly-snippets | autocomplete e snippets |
| **mini.nvim** | `mini.pairs`, `mini.surround`, `mini.ai`, `mini.icons` (um repositório só) |
| nvim-ts-autotag, emmet-vim | tags JSX/HTML e abreviações Emmet |
| tabout.nvim | pular para fora de aspas/parênteses com `Tab` |
| conform.nvim, nvim-lint | formatação ao salvar e lint |
| mason.nvim | instala LSPs, linters e formatadores (apenas o `PATH`; sem mason-lspconfig) |
| nvim-dap, nvim-dap-ui, nvim-nio, nvim-dap-go | debug (Go + C via codelldb) |
| neotest, neotest-golang | rodar testes Go com resultado por caso de tabela |
| gopher.nvim | `if err != nil`, tags de struct, comentário de doc |
| code_runner.nvim | executa o arquivo atual |
| multicursor.nvim | múltiplos cursores |
| flash.nvim | salto por labels |
| fzf-lua | busca fuzzy de arquivo/texto, com preview |
| oil.nvim, oil-git-status.nvim | explorador de arquivos como buffer, com status do git |
| gitsigns.nvim, neogit | sinais de git por linha e interface de git |
| tiny-inline-diagnostic, tiny-cmdline | diagnóstico inline e cmdline flutuante |
| smart-splits.nvim | navegação contínua entre splits do Neovim e painéis do WezTerm |
| live-server.nvim | servidor HTTP local com live-reload |
| image.nvim | imagens no buffer (carrega só ao abrir imagem/markdown) |
| ccc.nvim | seletor de cor + cor desenhada no texto (CSS/HTML/JS/TS) |
| nvim-hlslens | `[posição/total]` ao lado dos resultados de busca |

> **kulala.nvim** (cliente HTTP, arquivos `.http`/`.rest`) está **desativado**: a linha está comentada em `lazy.lua`. O `plugins/http.lua` e os atalhos `<leader>h*` existem, mas só funcionam se o plugin for reativado (e ele precisa do `tree-sitter-cli`).

## LSP

| Servidor | Filetypes | Formatação |
|---|---|---|
| gopls | go, gomod, gowork | gofmt + organizeImports ao salvar |
| ts_ls | javascript, javascriptreact, typescript, typescriptreact | prettier |
| lua_ls | lua | stylua |
| html | html, gotmpl (templates Go) | prettier |
| cssls | css, scss, less | prettier |
| htmx | html, gotmpl | — |
| clangd | c, cpp, objc, objcpp | clang-format |

O `gopls` está com `completionBudget = "500ms"` (padrão 100ms): em disco lento ou externo ele estourava o orçamento e cortava sugestões.

## Atalhos

`<leader>` = `Espaço`. Gramática: `<leader>` + **domínio** + **verbo**.

| Domínio | Assunto | Domínio | Assunto |
|---|---|---|---|
| `b` | buffers | `m` | multicursor |
| `f` | find / arquivos / LSP | `d` | debug |
| `g` | Go | `r` | run |
| `j` | JavaScript | `u` | testes (neotest) |
| `l` | live-server | `v` | git (Neogit) |
| `t` | terminal | `e` | explorador (oil) |
| `c` | cor (`<leader>cc`) | `h` | HTTP (desativado) |

Fora da gramática, por convenção do ecossistema: `gd`/`K`/`[d`/`]d` (LSP), `]b`/`[b` (buffers), `]f`/`[f`/`]c`/`[c` (textobjects), `gf`, `s`/`S` (flash).

⚠️ Não confundir: `<leader>bd` (buffer → fechar) × `<leader>db` (debug → breakpoint).

**Arquivos e busca:** `<leader>e` explorador (oil, substitui o buffer) · `<leader>fe` oil em split vertical · `<leader>ff` buscar arquivo pelo nome · `<leader>fg` buscar texto (grep) · `gf` abrir/criar o arquivo sob o cursor · `<leader>fn` novo arquivo · `<leader>fd` reabrir o dashboard · `<leader>n`/`<leader>w` nova/fechar tabpage

**Buffers:** `<leader>bd` fechar · `<leader>bx` fechar forçado · `]b`/`[b` próximo/anterior (a tabline lista os buffers; clique esquerdo troca, clique do meio fecha)

**LSP:** `gd` definição (`Ctrl+o` volta, `Ctrl+i` avança) · `K` hover · `[d`/`]d` diagnóstico anterior/próximo · `<leader>fr` rename · `<leader>fu` referências

**Autocomplete:** `Enter` aceita · `Ctrl+Space` abre · `Ctrl+e` fecha · `↑`/`↓` e `Shift+Tab` navegam · `Ctrl+d`/`Ctrl+u` rolam a documentação · `Ctrl+j`/`Ctrl+k` avançam/voltam no snippet · `Tab` pula para fora de aspas/parênteses (em arquivos HTML/CSS/JSX/TSX avança na lista ou expande Emmet)

**Textobjects:** `af`/`if` função · `ac`/`ic` struct/class · `aa`/`ia` parâmetro · `]f`/`[f` e `]c`/`[c` navegam sem selecionar

**Busca:** `n`/`N`/`*`/`#`/`g*`/`g#` com contador `[posição/total]` · `s` salto por labels (flash), `S` por treesitter, `Ctrl+s` liga o flash dentro de `/`

**Go:** `<leader>gt` testar pacote · `<leader>ga` testar tudo · `<leader>gr` testar a função sob o cursor · `<leader>ge` gerar `if err != nil` · `<leader>gs` adicionar tag `json` na struct (salve o arquivo antes) · `<leader>gc` gerar comentário de documentação

**Testes (neotest, Go):** `<leader>us` o mais próximo · `uf` arquivo · `ua` projeto · `ud` depurar · `ux` parar · `uo` saída · `up` painel de resumo

**JavaScript** (`node --test`): `<leader>jt` arquivo · `<leader>ja` projeto (`npm test` se houver script `test`) · `<leader>jr` o teste sob o cursor · `<leader>jw` modo watch · `<leader>jn` REPL do Node

**Debug:** `F5`/`F10`/`F11`/`F12` ou `<leader>d{b,x,c,o,i,k,r,t,u}` (breakpoint, limpar, continue, step over/into/out, REPL, terminar, UI)

**Multicursor:** `Ctrl+↑`/`Ctrl+↓` (ou `Ctrl+k`/`Ctrl+j`) cursor acima/abaixo · `<leader>mn`/`mp` próxima/anterior ocorrência · `<leader>ma` todas · `<leader>mx` remover · `<leader>mq` ligar/desligar

**Terminal:** `<leader>t` horizontal · `<leader>ts` vertical · `Ctrl+t` alterna · no modo terminal: `Esc` sai do modo, `Ctrl+w` navega splits, `Ctrl+q` fecha

**Runner:** `<leader>r` executar arquivo · `<leader>rp` executar projeto

**Git:** `<leader>v` abre o Neogit

**Live-server:** `<leader>ls` iniciar · `lo` abrir · `lr` recarregar · `lt` ligar/desligar live-reload · `li` status · `lS` parar um · `lA` parar todos

**Cor:** `<leader>cc` abre o seletor de cor com o cursor sobre uma cor (`h`/`l` ajustam o slider, `Enter` confirma, `q` cancela)

**Splits e WezTerm:** `Alt+h/j/k/l` navegam entre splits do Neovim e painéis do WezTerm · `Alt+\` volta ao anterior (só se a versão instalada do `smart-splits` tiver essa função; senão aparece um aviso)

A lista completa dos atalhos globais com `desc` pode ser gerada com `:MartiniDocKeymaps`.

## Explorador de arquivos (oil.nvim)

Sem netrw: o `oil.nvim` assume qualquer diretório aberto. Ele edita a listagem como texto — apagar a linha apaga o arquivo, `yy` + `p` move, editar o nome renomeia — e **nada toca o disco até `:w`** (que mostra um resumo antes de aplicar). `Tab` ou `Enter` abre o arquivo sob o cursor, `-` sobe um nível, `g?` lista os atalhos internos.

Pastas de sistema do NTFS (`$RECYCLE.BIN`, `System Volume Information`, `.Trash-<n>`) ficam sempre ocultas: abri-las derruba o oil com `assertion failed` em volumes Windows montados no Linux.

## Busca (fzf-lua)

Janela centralizada, preview à direita e cores integradas à paleta do `colors.lua`. Busca por **nome de arquivo** (`<leader>ff`) ou **texto** (`<leader>fg`) a partir da pasta atual do Neovim — não navega pastas (isso é papel do oil). Para buscar em outra pasta, abra o Neovim a partir dela ou use `:cd`.

## Dashboard

Tela inicial via `snacks.nvim`: banner, menu (`n` novo, `f` buscar arquivo, `g` buscar texto, `e` explorador, `t` terminal, `l` Lazy, `c` config, `q` sair), arquivos recentes, git status (cacheado 5 min) e tempo de boot. Reabra com `<leader>fd`.

## Cores

Toda cor da interface mora em `config/colors.lua`. As strings usam um verde próprio (`green_str`), mais escuro que o verde dos demais elementos, para que os verbos de formatação (`%s`, `%d`, em amarelo) se destaquem.

## Atualização de plugins

Sem atualização automática em background — decisão explícita, para não regravar o `lazy-lock.json` sozinho. `:MartiniUpdate` abre a UI do `lazy.nvim` para você revisar e confirmar. Para instalar plugins recém-adicionados à lista use `:Lazy sync` e reinicie o Neovim.
