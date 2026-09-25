-- =========================================================
-- lua/martini/plugins/flash.lua
-- folke/flash.nvim — navegação por labels (salto rápido pra
-- qualquer ponto visível na tela, sem contar linhas/colunas).
--
-- Teclas seguem a convenção oficial do próprio plugin (fora da
-- gramática <leader>+domínio+verbo, mesmo caso de gd/K/[d/]d — ver
-- cabeçalho de config/keymaps.lua): "s" sobrescreve o "substitute"
-- nativo do Neovim, que na prática quase ninguém usa sem contar
-- caractere (cs/ds do nvim-surround cobre o caso real de "trocar
-- around/inside").
--
-- ATENÇÃO DE DESEMPENHO (25/09/2026, ver conversa): há relato aberto
-- no repositório oficial de travamento de alguns segundos em busca
-- (`/`) dentro de arquivos muito grandes com padrão repetido em
-- excesso (milhares de ocorrências do termo buscado) — não é o
-- tamanho do arquivo em si que pesa, é a quantidade de matches. Sem
-- confirmação de correção oficial até a versão atual.
-- =========================================================
local safe_require = require("martini.utils.safe_require")

safe_require("flash", function(flash)
  flash.setup({
    modes = {
      search = {
        enabled = true,
      },
    },
  })

  vim.keymap.set({ "n", "x", "o" }, "s", function()
    require("flash").jump()
  end, { desc = "Flash" })

  vim.keymap.set({ "n", "x", "o" }, "S", function()
    require("flash").treesitter()
  end, { desc = "Flash Treesitter" })

  vim.keymap.set("o", "r", function()
    require("flash").remote()
  end, { desc = "Remote Flash" })

  vim.keymap.set({ "o", "x" }, "R", function()
    require("flash").treesitter_search()
  end, { desc = "Treesitter Search" })

  vim.keymap.set("c", "<C-s>", function()
    require("flash").toggle()
  end, { desc = "Toggle Flash Search" })
end, "navegação por labels (flash.nvim)")
