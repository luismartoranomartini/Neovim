-- =========================================================
-- lua/martini/config/keymaps.lua
-- Atalhos globais de teclado
-- GRAMÁTICA: <leader> + [DOMÍNIO] + [VERBO]
-- 1ª letra depois do <leader> = DOMÍNIO (o quê)
-- 2ª letra = VERBO (a ação dentro do domínio)
--   b → buffers          f → find/arquivos (LSP + gf/fn)
--   m → multicursor       g → Go
--   d → debug             r → run (code_runner)
--   h → HTTP (kulala)
-- Sem maiúsculas nos atalhos <leader> (ergonômico — fácil de errar
-- sob pressão). gd/K/[d/]d (LSP) ficam FORA dessa gramática de
-- propósito — convenção universal do ecossistema Neovim.
--
-- REDUÇÃO (set/2026): <leader>ff/<leader>fg (busca nativa via
-- :find/:grep) removidos daqui — fzf-lua (plugins/finder.lua,
-- <C-p>/<C-g>) já cobre os dois casos com preview visual, e manter
-- os dois caminhos era duplicidade sem propósito real. Os comandos
-- :find/:grep continuam disponíveis via linha de comando (ver
-- config/options.lua), só sem atalho <leader> dedicado.
--
-- NETRW → OIL (09/09/2026): <leader>e trocou de ":Lexplore" (netrw)
-- pra ":Oil" (stevearc/oil.nvim, plugins/oil.lua) — netrw saiu de
-- cena por completo, ver notas em lazy.lua e plugins/oil.lua.
-- IMPORTANTE: o keymap real de <leader>e agora é registrado DENTRO
-- de plugins/oil.lua (setup do plugin), não aqui — cada plugin
-- registra seus próprios keymaps de invocação junto do setup(),
-- mesmo padrão já usado por <leader>fd (dashboard, ver abaixo) e
-- pelos atalhos de debug (ver dbg() mais abaixo neste arquivo).
--
-- PENDENTE (09/09/2026): <leader>n/<leader>w abaixo criam/fecham
-- TABPAGES nativas — mas a tabline agora (config/tabline.lua) lista
-- BUFFERS, não tabpages. Os dois continuam funcionando sem erro,
-- só não geram mais "aba nova" na tabline visível. Decidir depois se
-- isso fica assim, muda de gramática, ou os dois somem.
-- =========================================================

local path = require("martini.utils.path")
local terminal = require("martini.utils.terminal")

-- ── Arquivos e navegação ─────────────────────────────────
vim.keymap.set("n", "<leader>n", ":tabnew<CR>")
vim.keymap.set("n", "<leader>w", ":tabclose<CR>", { desc = "Fechar aba atual" })

-- <leader>e (explorador de arquivos) é registrado em plugins/oil.lua,
-- junto do setup do oil.nvim — ver nota "NETRW → OIL" acima.

-- Cria/abre arquivo sob o cursor em nova aba (ver utils/path.lua)
vim.keymap.set("n", "gf", path.goto_or_create,
  { desc = "Criar/Abrir arquivo sob o cursor (relativo à pasta atual)" })

-- Comando explícito de "novo arquivo", separado do gf (que continua
-- semanticamente "go to file"). Agrupado sob <leader>f = domínio Find.
vim.keymap.set("n", "<leader>fn", path.new_file, { desc = "Find: novo arquivo (com mkdir -p)" })

-- Reabre o dashboard (snacks.nvim) a qualquer momento, sem precisar
-- fechar o Neovim e abrir de novo.
vim.keymap.set("n", "<leader>fd", function() Snacks.dashboard() end, { desc = "Find: abrir dashboard" })

-- ── Buffers ───────────────────────────────────────────────
vim.keymap.set("n", "<leader>bd", ":bd<CR>", { desc = "Fechar buffer" })
vim.keymap.set("n", "<leader>bx", ":bd!<CR>", { desc = "Fechar buffer (forçado)" })

-- ]b/[b (09/09/2026): navega entre buffers — mesma lógica de ficar
-- FORA da gramática <leader>+domínio+verbo que já vale pra gd/K/[d/]d
-- (convenção universal do ecossistema Neovim, ver cabeçalho). Motivo
-- de existir agora: a tabline (config/tabline.lua) lista buffers
-- como abas, mas só clique de mouse trocava de buffer até aqui —
-- isso dá um caminho de teclado equivalente.
vim.keymap.set("n", "]b", ":bnext<CR>", { desc = "Próximo buffer" })
vim.keymap.set("n", "[b", ":bprevious<CR>", { desc = "Buffer anterior" })

-- ── Terminal ──────────────────────────────────────────────
vim.keymap.set("n", "<leader>t", terminal.open_horizontal, { desc = "Abrir terminal (split horizontal)" })
vim.keymap.set("n", "<leader>vs", terminal.open_vertical, { desc = "Abrir terminal (split vertical)" })
vim.keymap.set("n", "<C-t>", terminal.toggle, { desc = "Toggle terminal" })

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Sair do modo terminal" })
vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>", { desc = "Navegar splits de dentro do terminal" })
vim.keymap.set("t", "<C-q>", "<C-\\><C-n><C-w>q", { desc = "Fechar terminal" })
vim.keymap.set("t", "<C-t>", "<C-\\><C-n><C-w>q", { desc = "Fechar terminal com Ctrl+t" })

-- ── Debug (nvim-dap / dap-ui) ─────────────────────────────
-- Carregado sob demanda: martini.plugins.debug.setup() só roda
-- dapui/dap-go/codelldb na PRIMEIRA ação de debug, não no boot.
local function dbg()
  require("martini.plugins.debug").setup()
  return require("dap")
end

-- Teclas de função — convenção universal de debugger (VSCode, JetBrains, etc.)
vim.keymap.set("n", "<F5>", function() dbg().continue() end, { desc = "Debug: continuar / iniciar" })
vim.keymap.set("n", "<F10>", function() dbg().step_over() end, { desc = "Debug: passo sobre (step over)" })
vim.keymap.set("n", "<F11>", function() dbg().step_into() end, { desc = "Debug: passo para dentro (step into)" })
vim.keymap.set("n", "<F12>", function() dbg().step_out() end, { desc = "Debug: passo para fora (step out)" })

-- Aliases <leader>d* — mesmas ações, para quem prefere não tirar a mão
-- da home row / não decorar teclas de função.
vim.keymap.set("n", "<leader>db", function() dbg().toggle_breakpoint() end, { desc = "Debug: breakpoint (linha atual)" })
vim.keymap.set("n", "<leader>dx", function() dbg().clear_breakpoints() end, { desc = "Debug: limpar TODOS os breakpoints" })
vim.keymap.set("n", "<leader>dc", function() dbg().continue() end, { desc = "Debug: continuar / iniciar" })
vim.keymap.set("n", "<leader>do", function() dbg().step_over() end, { desc = "Debug: passo sobre" })
vim.keymap.set("n", "<leader>di", function() dbg().step_into() end, { desc = "Debug: passo para dentro" })
vim.keymap.set("n", "<leader>dk", function() dbg().step_out() end, { desc = "Debug: passo para fora" })
vim.keymap.set("n", "<leader>dr", function() dbg().repl.open() end, { desc = "Debug: abrir REPL" })
vim.keymap.set("n", "<leader>dt", function() dbg().terminate() end, { desc = "Debug: encerrar sessão" })
vim.keymap.set("n", "<leader>du", function()
  require("martini.plugins.debug").setup()
  require("dapui").toggle()
end, { desc = "Debug: interface visual" })

-- ── Code runner ───────────────────────────────────────────
vim.keymap.set("n", "<leader>r", ":RunCode<CR>", { desc = "Executar arquivo atual" })
vim.keymap.set("n", "<leader>rp", ":RunProject<CR>", { desc = "Executar projeto" })
