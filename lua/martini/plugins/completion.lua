-- =========================================================
-- lua/martini/plugins/completion.lua
-- blink.cmp + LuaSnip (motor de snippet) + capabilities LSP + Emmet no
-- <Tab>. Carrega ANTES de plugins/lsp.lua: define vim.lsp.config["*"]
-- com as capabilities do blink.cmp, que os servidores individuais
-- herdam.
--
-- BLINK.CMP (27/09/2026): substitui nvim-cmp + cmp-nvim-lsp +
-- cmp-buffer + cmp_luasnip — ver nota "BLINK.CMP / MINI.PAIRS / MINI.
-- SURROUND / LUALINE" em lazy.lua pro motivo geral. LuaSnip CONTINUA
-- instalado, mas so como motor de snippet (snippets = { preset =
-- "luasnip" } abaixo) — ele mesmo nao e mais fonte de completion
-- separada, quem cuida disso agora e o provider "snippets" do blink.
--
-- HISTORICO preservado do nvim-cmp (ainda vale com blink.cmp):
-- Navegar entre itens do autocomplete e <Down>/<Up>, nao <Tab>/<S-Tab>.
-- Jump de snippet (placeholders das snippets Go customizadas: iferr,
-- forr, main, test, struct) fica em <C-j>/<C-k>, modo insert/select —
-- sem colisao com <C-j>/<C-k> do multicursor (plugins/multicursor.lua),
-- que so mapeia em modo normal/visual.
--
-- ISOLADO POR FILETYPE: <Tab> so dispara Emmet em html, css, scss,
-- jsx, tsx — mesma lista de plugins/editing.lua, onde :EmmetInstall
-- roda (user_emmet_install_global = 0, emmet NUNCA instalado fora
-- desses filetypes). LISTA DUPLICADA de proposito (mesma de
-- editing.lua): sao 5 nomes, nao vale a pena um modulo compartilhado
-- so pra isso — se mudar uma lista, mudar a outra tambem.
--
-- TABOUT: o <Tab> GENERICO (fora dos 5 filetypes de Emmet) e 100% do
-- tabout.nvim (ver plugins/tabout.lua) — pula pra fora de aspas/
-- parenteses/chaves quando o cursor esta logo antes de um fechamento.
-- Os 5 filetypes de Emmet continuam com <Tab> definido AQUI, como
-- mapeamento LOCAL AO BUFFER (autocmd FileType abaixo) — mapeamento
-- local tem prioridade sobre o global do tabout, entao o Emmet nesses
-- filetypes especificos continua intocado.
-- =========================================================

local safe_require = require("martini.utils.safe_require")

local luasnip = safe_require.get("luasnip", "motor de snippet (usado pelo blink.cmp)")

if luasnip then
  safe_require("luasnip.loaders.from_vscode", function(loader)
    loader.lazy_load()
  end, "snippets prontos (friendly-snippets)")

  -- Snippets Go customizados (09/09/2026) — friendly-snippets nao
  -- cobre Go nenhum (conferido no pacote antes de escrever isso).
  -- Ver lua/martini/snippets/go.lua pro conteudo real.
  safe_require("luasnip.loaders.from_lua", function(loader)
    loader.load({ paths = vim.fn.stdpath("config") .. "/lua/martini/snippets" })
  end, "snippets Go customizados (iferr, forr, main, test, struct)")
end

safe_require("blink.cmp", function(blink)
  vim.lsp.config["*"] = { capabilities = blink.get_lsp_capabilities() }

  blink.setup({
    keymap = {
      preset = "none",
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<CR>"] = { "select_and_accept", "fallback" },
      ["<C-e>"] = { "hide", "fallback" },
      ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      ["<C-u>"] = { "scroll_documentation_up", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<Up>"] = { "select_prev", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      -- <Tab> generico fica de fora de proposito — ver nota "TABOUT"
      -- no topo do arquivo.
    },
    completion = {
      documentation = { auto_show = true },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    snippets = { preset = "luasnip" },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  })

  -- <C-j>/<C-k> pro jump de snippet do LuaSnip — independente do
  -- blink, mesmo comportamento de antes (ver nota no topo do arquivo).
  if luasnip then
    vim.keymap.set({ "i", "s" }, "<C-j>", function()
      if luasnip.expand_or_jumpable() then luasnip.expand_or_jump() end
    end, { desc = "Snippet: expandir/avancar" })
    vim.keymap.set({ "i", "s" }, "<C-k>", function()
      if luasnip.jumpable(-1) then luasnip.jump(-1) end
    end, { desc = "Snippet: voltar" })
  end
end, "autocomplete (blink.cmp)")

-- <Tab> LOCAL AO BUFFER pros filetypes de Emmet — ver nota "TABOUT" e
-- "ISOLADO POR FILETYPE" no topo do arquivo. Mapeamento por buffer
-- (nao global) tem prioridade sobre o <Tab> global do tabout.nvim,
-- entao nesses 5 filetypes o comportamento continua: menu do blink
-- visivel → navega; senao → expande Emmet.
local emmet_filetypes = { "html", "css", "scss", "javascriptreact", "typescriptreact" }
vim.api.nvim_create_autocmd("FileType", {
  pattern = emmet_filetypes,
  callback = function(args)
    vim.keymap.set("i", "<Tab>", function()
      local ok_blink, blink = pcall(require, "blink.cmp")
      if ok_blink and blink.is_visible() then
        blink.select_next()
      else
        vim.schedule(function()
          vim.fn.feedkeys(
            vim.api.nvim_replace_termcodes("<plug>(emmet-expand-abbr)", true, false, true), ""
          )
        end)
      end
    end, { buffer = args.buf, desc = "blink: proximo item, ou expandir Emmet" })
  end,
})
