-- =========================================================
-- lua/martini/config/netrw.lua
-- Ajustes e workarounds específicos do explorador nativo (netrw).
-- Centralizados aqui em vez de espalhados em options.lua/keymaps.lua
-- pra ter um único lugar óbvio pra olhar quando o netrw der problema.
-- =========================================================

-- MOVIDO de options.lua (07/09/2026) — mesmo comentário original:
-- Mantém o diretório de trabalho do Neovim sincronizado com a pasta
-- que o netrw está navegando. Sem isso, R (renomear) preenche o
-- caminho absoluto inteiro em vez de só o nome do arquivo sempre que
-- os dois divergem (comum ao navegar entre volumes/pastas distantes
-- de onde o Neovim foi aberto).
vim.g.netrw_keepdir = 0

-- CORREÇÃO (07/09/2026): E471 "Argument required: keepj keepalt
-- 2wincmd 1" ao abrir arquivo pelo :Lexplore.
--
-- Bug conhecido do próprio netrw (vim/vim#20741, "fix E471 in Neovim
-- when g:netrw_chgwin is one past the last window"): toda vez que o
-- :Lexplore abre, ele seta g:netrw_chgwin pro número da janela de
-- origem. Se o layout de janelas mudar depois disso (fechar/abrir
-- split), esse número pode passar a apontar uma janela além da
-- última que existe — e o cálculo interno do split de resgate que o
-- netrw tenta fazer quebra, gerando esse erro.
--
-- Reseta g:netrw_chgwin pra -1 (valor que o netrw trata como "não
-- definido") toda vez que a janela do netrw fecha, pra nunca carregar
-- um número obsoleto pra próxima vez que :Lexplore abrir.
vim.api.nvim_create_autocmd("WinClosed", {
  desc = "Reset netrw_chgwin ao fechar o netrw (evita E471, ver vim/vim#20741)",
  callback = function(args)
    local winid = tonumber(args.match)
    if not winid then return end
    local ok, buf = pcall(vim.api.nvim_win_get_buf, winid)
    if ok and vim.bo[buf].filetype == "netrw" then
      vim.g.netrw_chgwin = -1
    end
  end,
})
