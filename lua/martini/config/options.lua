-- =========================================================
-- lua/martini/config/options.lua
-- Configurações de comportamento e editor (puro vim.opt/vim.g)
-- Diagnósticos ficaram em config/diagnostics.lua.
-- =========================================================
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.clipboard = "unnamedplus"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.fillchars = { vert = "│" }
vim.opt.colorcolumn = "120"
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.textwidth = 100
vim.opt.termguicolors = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.guifont = "FiraCode Nerd Font Mono:h11"
vim.o.completeopt = "menu,menuone,noselect"

-- Mantém o diretório de trabalho do Neovim sincronizado com a pasta
-- que o netrw está navegando. Sem isso, R (renomear) preenche o
-- caminho absoluto inteiro em vez de só o nome do arquivo sempre que
-- os dois divergem (comum ao navegar entre volumes/pastas distantes
-- de onde o Neovim foi aberto).
vim.g.netrw_keepdir = 0

-- Aviso visual de arquivo não salvo, mais chamativo que o [+] padrão
-- do Neovim — usa o grupo de highlight DiagnosticWarn (já definido
-- por config/diagnostics.lua), então a cor já combina com o resto.
-- Fica na FRENTE do nome do arquivo (antes, não depois).
vim.o.statusline = "%#StatusLineModified#%{&modified ? ' ● UNSAVED ' : ''}%*%f %h%r%=%-14.(%l,%c%V%) %P"

-- Cursor em formato de barra vertical (em vez do bloco padrão) apenas
-- dentro do modo Terminal ("t"). Não altera o cursor nos outros modos.
vim.opt.guicursor:append("t:ver25")

-- Fold baseado em Treesitter — recolher/expandir funções e blocos com
-- za (alterna) / zc (fecha) / zo (abre) / zR (abre tudo) / zM (fecha tudo).
-- Funciona pra qualquer linguagem com parser Treesitter instalado (Go,
-- JS/TS, C etc.), sem precisar de plugin extra.
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99 -- abre tudo por padrão ao abrir o arquivo — sem
-- isso o Neovim abre o arquivo com tudo recolhido.

-- Busca de arquivo/texto nativa (:find / :grep) — comandos sempre
-- disponíveis, mesmo sem atalho <leader> dedicado (a busca fuzzy do
-- dia a dia é fzf-lua, ver plugins/finder.lua: <C-p>/<C-g>).
-- "**" faz :find buscar recursivamente a partir do diretório de
-- trabalho atual, não só na pasta do arquivo aberto.
vim.opt.path:append("**")

-- Ignora essas pastas tanto na busca de :find quanto no wildmenu de
-- autocomplete de caminho (:e <Tab>, por exemplo).
vim.opt.wildignore:append({
  "*/node_modules/*",
  "*/.git/*",
  "*/vendor/*", -- pasta padrão de dependências vendored do Go
})

-- :grep usa ripgrep se disponível no PATH (muito mais rápido que o
-- grep interno do Vim, que lê arquivo por arquivo em Vimscript).
if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep --smart-case"
  vim.opt.grepformat = "%f:%l:%c:%m"
end

-- Quebra de linha AUTOMÁTICA (hard wrap) ao ultrapassar textwidth (100),
-- restrita a arquivos de TEXTO/PROSA — markdown, mensagens de commit,
-- texto puro, reStructuredText, AsciiDoc, LaTeX. A flag "t" do
-- formatoptions insere uma quebra de linha de verdade enquanto você
-- digita — diferente de wrap/linebreak acima, que só quebram
-- visualmente sem alterar o conteúdo do arquivo.
-- IMPORTANTE: formatoptions global é sempre sobrescrito pelos ftplugins
-- embutidos do Neovim (ex.: /usr/share/nvim/runtime/ftplugin/markdown.vim
-- roda "setlocal formatoptions=..." ao abrir o arquivo). Por isso é
-- reaplicado via autocmd FileType, que roda DEPOIS do ftplugin embutido.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "gitcommit", "text", "rst", "asciidoc", "tex" },
  callback = function()
    vim.opt_local.formatoptions:append("t")
  end,
})
