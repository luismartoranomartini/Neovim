-- =========================================================
-- lua/martini/plugins/oil.lua
-- Explorador de arquivos (stevearc/oil.nvim), substituindo netrw por
-- completo — arquivo NOVO no lugar de netrw-icons.lua (REMOVIDO).
--
-- Edita o filesystem como um buffer de texto normal: cada linha é uma
-- entrada; deletar a linha deleta o arquivo, yy+p move, editar o
-- texto renomeia. Nada disso toca o disco até :w — sempre dá pra
-- revisar com "diff" antes de confirmar.
--
-- default_file_explorer = true faz oil assumir TODO diretório aberto
-- (nvim ., :e <pasta>) — netrw nunca mais entra em cena, nem como
-- fallback. Sem isso, os dois disputariam quem abre primeiro.
--
-- :Oil (sem argumento) SUBSTITUI o buffer atual — não abre split.
-- Decisão explícita: replica o comportamento do repo de referência
-- (github.com/FractalCodeRicardo/dev-config/tree/master/nvim/lua/
-- plugins/oil.lua), que também não usa split. Isso é uma MUDANÇA de
-- hábito em relação ao :Lexplore antigo (que abria em split vertical,
-- deixando o arquivo em edição visível ao lado) — se isso incomodar
-- no uso real, dá pra abrir com ":vsplit | Oil" manualmente, ou
-- promover isso a keymap depois.
--
-- Provedor de ícone: mini.icons, NÃO nvim-web-devicons — mesma
-- decisão do repo de referência (ver nota em lazy.lua). Confirmado
-- antes da troca que fzf-lua (plugins/finder.lua) e o dashboard
-- (plugins/dashboard.lua) não dependiam de nvim-web-devicons.
--
-- keymap <leader>e (em vez do "te" sem <leader> do repo de
-- referência): mantém a gramática já estabelecida em config/
-- keymaps.lua (<leader> + domínio + verbo) e o mesmo lugar onde o
-- netrw já vivia — só troca o QUE abre, não ONDE.
--
-- <leader>fe (09/09/2026): abre o oil em split vertical, SEM
-- substituir o buffer atual — pra quando você quer ver o explorador
-- e o arquivo em edição ao mesmo tempo (comportamento visual que o
-- :Lexplore antigo tinha por padrão, e <leader>e não tem mais desde
-- a troca pro oil). Domínio "f" (find/arquivos — mesmo grupo de
-- <leader>fn/<leader>fd), verbo "e" (explorer, em split).
-- =========================================================
require("mini.icons").setup()

require("oil").setup({
  default_file_explorer = true,
  view_options = {
    show_hidden = true,
    -- Pastas de sistema do NTFS (comuns em volumes Windows montados,
    -- ver /run/media/.../Luis/ nas notas de ambiente) — permissão
    -- restrita faz uv.fs_stat falhar nelas, e o fallback do oil pra
    -- descobrir o tipo (vim.filetype.match -> vim.fs.abspath) crasha
    -- com "assertion failed" em vez de simplesmente tratar como
    -- arquivo comum. Escondidas sempre, mesmo com show_hidden = true
    -- — não há motivo pra abrir essas pastas de dentro do oil.
    is_always_hidden = function(name, _)
      local pastas_sistema_ntfs = {
        ["$RECYCLE.BIN"] = true,
        ["System Volume Information"] = true,
      }
      return pastas_sistema_ntfs[name] == true or name:match("^%.Trash%-%d+$") ~= nil
    end,
  },
})

vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Explorador de arquivos (oil)" })

-- <leader>fe: mesma coisa, mas em split vertical (ver nota acima) —
-- o buffer em edição continua visível na janela original.
vim.keymap.set("n", "<leader>fe", "<CMD>vsplit | Oil<CR>",
  { desc = "Find: explorador de arquivos (oil, split vertical)" })

-- Números de linha dentro do buffer do oil — absoluto + relativo,
-- igual ao repo de referência. Ajuda a mirar em mm/yy/dd por
-- quantidade de linhas quando movendo/copiando várias entradas.
vim.api.nvim_create_autocmd("FileType", {
  desc = "Números de linha (absoluto + relativo) no buffer do oil",
  pattern = "oil",
  callback = function()
    vim.opt_local.number = true
    vim.opt_local.relativenumber = true
  end,
})
