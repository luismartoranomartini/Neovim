-- =========================================================
-- lua/martini/health.lua
-- :checkhealth martini
--
-- Verifica os binários externos documentados no README ("Requisitos")
-- — nada aqui reconfigura nada, é só diagnóstico. Usa a mesma técnica
-- de detecção (vim.fn.exepath) já usada em lsp.lua/debug.lua/go.lua,
-- só que reunida num lugar só, pra checar tudo de uma vez ao trocar
-- de máquina (Arch ↔ Fedora ↔ Windows).
--
-- Cada bloco abaixo espelha uma linha do README. Se o README ganhar
-- ou perder uma dependência, este arquivo precisa acompanhar — não
-- há geração automática (isso é outra tarefa, item 10 da revisão).
-- =========================================================

local M = {}

-- Roda vim.fn.exepath uma vez e reporta ok/warn, com uma dica de
-- instalação opcional quando ausente.
local function checar(nome, dica)
  local caminho = vim.fn.exepath(nome)
  if caminho ~= "" then
    vim.health.ok(nome .. " (" .. caminho .. ")")
  else
    vim.health.warn(nome .. " não encontrado no PATH", dica)
  end
end

function M.check()
  -- ── Neovim e sistema base ────────────────────────────────
  vim.health.start("martini.nvim — Neovim e sistema")

  if vim.fn.has("nvim-0.12") == 1 then
    vim.health.ok("Neovim " .. tostring(vim.version()))
  else
    vim.health.error(
      "Neovim " .. tostring(vim.version()) .. " — abaixo da versão mínima (0.12)",
      "A config usa APIs nativas de LSP/diagnostic específicas do 0.12 (ex.: vim.diagnostic.jump). Atualize o Neovim."
    )
  end

  local so = "Linux/BSD"
  if vim.fn.has("win32") == 1 then
    so = "Windows"
  elseif vim.fn.has("mac") == 1 then
    so = "macOS"
  end
  vim.health.info("Sistema operacional detectado: " .. so)

  checar("git", "Necessário pro lazy.nvim clonar/atualizar plugins.")

  -- ── LSP ──────────────────────────────────────────────────
  vim.health.start("martini.nvim — LSP (plugins/lsp.lua)")
  checar("gopls", "go install golang.org/x/tools/gopls@latest")
  checar("typescript-language-server", "npm i -g typescript-language-server typescript")
  checar("vscode-html-language-server", "npm i -g vscode-langservers-extracted")
  checar("vscode-css-language-server", "npm i -g vscode-langservers-extracted")
  checar("clangd", "Pacote 'clang' ou 'clangd' do seu gerenciador (ex.: pacman -S clang)")

  -- ── Lint e formatação ────────────────────────────────────
  vim.health.start("martini.nvim — Lint e formatação (languages/go.lua, plugins/format.lua)")
  checar("golangci-lint", "https://golangci-lint.run/welcome/install/")
  checar("prettier", "npm i -g prettier")
  checar("clang-format", "Pacote 'clang' do seu gerenciador")

  -- ── Compiladores e runtimes (code runner) ────────────────
  vim.health.start("martini.nvim — Execução de código (plugins/runner.lua)")
  checar("gcc", "Necessário pra <leader>r em arquivos .c")
  checar("g++", "Necessário pra <leader>r em arquivos .cpp")
  checar("node", "Necessário pra <leader>r em arquivos .js")
  checar("npx", "Vem junto do Node.js — necessário pra <leader>r em arquivos .ts (via tsx)")

  -- ── Debug ────────────────────────────────────────────────
  vim.health.start("martini.nvim — Debug (plugins/debug.lua)")
  checar("dlv", "go install github.com/go-delve/delve/cmd/dlv@latest")
  checar("codelldb", "yay -S codelldb-bin (AUR) — sem isso, debug de C/C++ fica desativado, mas o resto da config funciona normalmente")

  -- ── Busca e navegação ────────────────────────────────────
  vim.health.start("martini.nvim — Busca e navegação (plugins/finder.lua, plugins/oil.lua)")
  checar("fd", "Necessário pra <C-p> (fzf-lua files)")
  checar("fzf", "Necessário pra <C-p>/<C-g>")
  checar("rg", "ripgrep — necessário pra <C-g> (fzf-lua live_grep)")
  checar("bat", "Opcional — sem ele, o preview do fzf-lua cai pra 'cat' simples")

  -- ── HTTP (kulala.nvim) ───────────────────────────────────
  vim.health.start("martini.nvim — HTTP (plugins/http.lua)")
  checar("curl", "Necessário pro kulala.nvim enviar requisições")
  checar("tree-sitter", "tree-sitter-cli — necessário pro parser do filetype http/rest")

  -- ── Abrir HTML no navegador ──────────────────────────────
  vim.health.start("martini.nvim — Abrir HTML no navegador (plugins/runner.lua)")
  if vim.fn.has("win32") == 1 then
    vim.health.ok("Windows detectado — usa 'cmd.exe /c start', já vem com o sistema")
  elseif vim.fn.has("mac") == 1 then
    checar("open", "Já vem com o macOS por padrão — se sumiu, algo está muito errado")
  else
    checar("xdg-open", "Pacote 'xdg-utils' do seu gerenciador (ex.: pacman -S xdg-utils)")
  end
end

return M
