-- =========================================================
-- lua/martini/plugins/otter.lua
-- Autocomplete de verdade dentro de <script>/<style> em arquivos
-- HTML (e templates Go, que languages/go.lua trata como "html").
--
-- POR QUE ISSO É NECESSÁRIO: o vscode-html-language-server (seu LSP
-- de HTML, ver plugins/lsp.lua) parou de dar autocomplete de JS
-- dentro de <script> — isso é limitação conhecida do servidor em si,
-- não da sua config (era diferente numa versão antiga e mais
-- descontinuada do html-languageserver).
--
-- COMO FUNCIONA: otter.nvim usa as queries de injection do Treesitter
-- (já cobertas pelo parser "html" instalado em plugins/treesitter.lua)
-- pra achar os blocos de JS/CSS dentro do HTML, cria um buffer oculto
-- só com esse trecho, e conecta o MESMO ts_ls/cssls que você já tem
-- configurado (plugins/lsp.lua) nesse buffer oculto. O resultado volta
-- pro cmp-nvim-lsp automaticamente — não precisa de keymap especial,
-- os atalhos normais (gd, K, autocomplete) já funcionam dentro do
-- <script>.
-- =========================================================

pcall(function()
  require("otter").setup({
    lsp = {
      diagnostic_update_events = { "BufWritePost", "InsertLeave" },
    },
    buffers = {
      set_filetype = true,
    },
  })
end)

-- Ativa pro JS dentro de <script> e CSS dentro de <style>. Cobre
-- tanto .html "puro" quanto .tmpl/.gohtml (languages/go.lua já seta
-- filetype=html pra esses, então o mesmo pattern "html" já pega os
-- dois casos).
vim.api.nvim_create_autocmd("FileType", {
  pattern = "html",
  callback = function()
    pcall(function()
      require("otter").activate({ "javascript", "css" }, true, true)
    end)
  end,
})
