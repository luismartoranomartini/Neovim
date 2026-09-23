-- =========================================================
-- lua/martini/plugins/neogit.lua
-- NeogitOrg/neogit — interface Git interativa (status, stage,
-- commit, push/pull, branches), inspirada no Magit do Emacs.
--
-- Integração com fzf-lua (23/09/2026): fzf_lua = true reaproveita o
-- picker que você já usa (ibhagwan/fzf-lua) pra seleção de menus
-- dentro do Neogit — sem precisar instalar telescope.nvim só pra
-- isso (o Neogit aceita só um dos dois, telescope OU fzf-lua).
-- =========================================================
require("neogit").setup({
  integrations = {
    fzf_lua = true,
  },
})
