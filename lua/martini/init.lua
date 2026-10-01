-- =========================================================
-- TARGET: Neovim 0.12 · Arch Linux
-- lua/martini/init.lua
-- Bootstrap: patch 0.12.2 + lazy.nvim + ordem de carregamento
-- =========================================================
-- =========================================================
-- VERSÃO MÍNIMA (09/09/2026)
-- A config depende de APIs específicas do Neovim 0.12 (ex.:
-- vim.diagnostic.jump, ver plugins/lsp.lua) e tem um patch dedicado
-- pro bug do 0.12.2 logo abaixo. Roda ANTES de tudo, inclusive do
-- patch — se a versão já está errada, é a primeira coisa que você
-- precisa saber. Abaixo de 0.12, não interrompe o carregamento (não
-- dá pra afirmar com certeza o que quebra e o que não quebra em
-- versões antigas sem testar) — só avisa alto e claro, em vez de
-- deixar você descobrir via um traceback confuso mais adiante.
-- =========================================================
if vim.fn.has("nvim-0.12") == 0 then
	vim.notify(
		"martini.nvim requer Neovim 0.12+ (versão atual: "
			.. tostring(vim.version())
			.. "). LSP/diagnostics usam APIs específicas do 0.12 — algumas partes da config"
			.. " provavelmente vão falhar. Rode :checkhealth martini para mais detalhes.",
		vim.log.levels.ERROR
	)
end
-- =========================================================
-- =========================================================
-- UI2 (27/09/2026, REATIVADO)
-- A causa real da quebra de <leader> era config/init.lua estar com o
-- conteudo errado (copia de plugins/init.lua), nao o ui2. Reativado
-- agora que a causa raiz foi corrigida - teste <leader> logo depois de
-- reabrir, antes de mexer em mais nada.
-- =========================================================
do
	local ok_ui2, ui2 = pcall(require, "vim._core.ui2")
	if ok_ui2 then
		ui2.enable({})
	else
		vim.notify(
			"martini.nvim: vim._core.ui2 nao encontrado - tiny-cmdline.nvim nao vai funcionar.",
			vim.log.levels.WARN
		)
	end
end
-- =========================================================
-- PATCH 0.12.2 (chave 'buf' em nvim_create_autocmd) REMOVIDO em
-- 01/10/2026: no 0.12.5 a chave é aceita nativamente (confirmado com
-- pcall(nvim_create_autocmd, "User", { buf = 0, ... }) → true). Se
-- voltar a usar esta config num Neovim 0.12.2, o bug volta — ver
-- histórico git pra recuperar o patch.
-- =========================================================
-- =========================================================
-- PLUGINS — bootstrap via lazy.nvim (set/2026, substitui loader.lua)
-- Ver lua/martini/lazy.lua pro motivo da troca e o que mudou.
-- =========================================================
local primeiro_boot = require("martini.lazy")
if primeiro_boot then
	vim.notify(
		"Plugins sendo instalados pelo lazy.nvim. Aguarde a janela terminar e reinicie o Neovim.",
		vim.log.levels.WARN
	)
	return
end
-- =========================================================
-- CONFIG — comportamento, aparência e atalhos
-- Delegado a config/init.lua (agregador correto, mesma lógica já
-- usada em plugins/init.lua abaixo) — inclui config/diagnostics.lua.
-- =========================================================
require("martini.config")
-- =========================================================
-- PLUGINS — configuração de cada plugin
-- Delegado a plugins/init.lua. UM único require aqui evita
-- duplicar/divergir a lista de plugins em dois arquivos.
-- =========================================================
require("martini.plugins")
