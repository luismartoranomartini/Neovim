-- =========================================================
-- lua/martini/plugins/live-server.lua
-- Servidor HTTP local com live-reload (selimacerbas/live-server.nvim)
-- — necessário pra htmx e qualquer AJAX/fetch em geral: abrir o HTML
-- direto (file://, que é o que <leader>r faz pra .html hoje via
-- runner.lua) não serve requisição nenhuma, só mostra o arquivo.
--
-- Domínio "l" (livre na gramática <leader>+domínio+verbo — não
-- colide com b/f/d/r/h/m/g já usados). Segundo letra = verbo, mesmo
-- padrão sugerido pela própria doc do plugin:
--   s start · o open · r reload · t toggle live-reload
--   i info/status · S stop um · A stop todos
--
-- SEM telescope.nvim nem which-key.nvim (dependências só
-- "recomendadas" pelo autor, não obrigatórias): sem telescope, o
-- picker de caminho/porta cai em vim.ui.select — que no seu caso já
-- é o fzf-lua (register_ui_select(), ver plugins/finder.lua), sem
-- perda de funcionalidade real. which-key é só cosmético (rótulo do
-- grupo no menu de atalhos), sem ele os atalhos funcionam idêntico.
--
-- auto_start deliberadamente OFF: preferi start manual (<leader>ls)
-- a subir servidor sozinho toda vez que abrir um .html, pra não
-- acumular processo à toa (mesma lição do terminal — ver
-- utils/terminal.lua).
-- =========================================================

local safe_require = require("martini.utils.safe_require")

safe_require("live_server", function(live_server)
  live_server.setup({
    default_port = 8000,
    live_reload = {
      enabled = true,
      inject_script = true,
      debounce = 120,
      css_inject = true, -- troca CSS sem recarregar a página inteira
    },
    directory_listing = {
      enabled = true,
      show_hidden = false,
    },
  })
end, "servidor HTTP local com live-reload (<leader>l*)")

local map = vim.keymap.set

map("n", "<leader>ls", "<CMD>LiveServerStart<CR>", { desc = "Live server: iniciar (escolhe caminho e porta)" })
map("n", "<leader>lo", "<CMD>LiveServerOpen<CR>", { desc = "Live server: abrir porta existente no navegador" })
map("n", "<leader>lr", "<CMD>LiveServerReload<CR>", { desc = "Live server: forçar reload" })
map("n", "<leader>lt", "<CMD>LiveServerToggleLive<CR>", { desc = "Live server: ativar/desativar live-reload" })
map("n", "<leader>li", "<CMD>LiveServerStatus<CR>", { desc = "Live server: status dos servidores ativos" })
map("n", "<leader>lS", "<CMD>LiveServerStop<CR>", { desc = "Live server: parar um (escolhe a porta)" })
map("n", "<leader>lA", "<CMD>LiveServerStopAll<CR>", { desc = "Live server: parar todos" })
