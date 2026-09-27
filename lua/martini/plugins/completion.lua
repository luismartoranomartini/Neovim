-- =========================================================
-- lua/martini/plugins/completion.lua
-- nvim-cmp + LuaSnip + capabilities LSP + Emmet no <Tab>.
-- Carrega ANTES de plugins/lsp.lua: define vim.lsp.config["*"] com as
-- capabilities do cmp_nvim_lsp, que os servidores individuais herdam.
--
-- SAFE_REQUIRE (09/09/2026): pcalls mudos trocados por
-- utils/safe_require.lua — ver nota completa em plugins/editing.lua.
-- Usa safe_require.get() (não a forma chamável direta) porque cmp E
-- luasnip precisam estar presentes ANTES de decidir configurar
-- qualquer coisa — não dá pra fazer "setup imediato" de um sem saber
-- se o outro também existe.
--
-- VOLTA DO <C-y> (18/09/2026): desfeito o "MEIO TERMO" de 09/09 —
-- Emmet volta pro <Tab>, sem checar cmp.visible() nem luasnip antes.
-- <C-y> não faz mais nada aqui, livre de novo. Navegar entre itens do
-- autocomplete passa a ser <Down>/<Up>, não mais <Tab>/<S-Tab>. Jump
-- de snippet (placeholders das snippets Go customizadas: iferr, forr,
-- main, test, struct) foi pra <C-j>/<C-k>, em modo insert/select —
-- sem colisão com <C-j>/<C-k> do multicursor (plugins/multicursor.lua),
-- que só mapeia em modo normal/visual.
--
-- ISOLADO POR FILETYPE (18/09/2026): <Tab> só dispara Emmet em html,
-- css, scss, jsx, tsx — mesma lista de plugins/editing.lua, onde
-- :EmmetInstall roda (user_emmet_install_global = 0, emmet NUNCA
-- instalado fora desses filetypes). LISTA DUPLICADA de propósito
-- (mesma de editing.lua): são 5 nomes, não vale a pena um módulo
-- compartilhado só pra isso — se mudar uma lista, mudar a outra
-- também.
--
-- <Tab>/<S-Tab> NAVEGAM O MENU (23/09/2026): quando cmp.visible(),
-- <Tab> seleciona o próximo item e <S-Tab> o anterior.
--
-- TABOUT (26/09/2026): o <Tab> GENÉRICO (fora dos 5 filetypes de
-- Emmet) saiu do cmp.mapping e passou a ser 100% do tabout.nvim (ver
-- plugins/tabout.lua) — ele pula pra fora de aspas/parênteses/chaves
-- quando o cursor está logo antes de um fechamento, e ainda coopera
-- com o cmp (completion = true: menu visível, o cmp navega; menu
-- fechado, o tabout tenta pular). Os 5 filetypes de Emmet continuam
-- com <Tab> definido AQUI, mas agora como mapeamento LOCAL AO BUFFER
-- (via autocmd FileType logo abaixo do cmp.setup) — mapeamento local
-- tem prioridade sobre o global do tabout, então o Emmet nesses
-- filetypes específicos continua intocado. <S-Tab> não muda: segue
-- 100% do cmp.mapping abaixo, o tabout nem registra tecla pra trás
-- (backwards_tabkey = "" em tabout.lua).
-- =========================================================

local safe_require = require("martini.utils.safe_require")

local cmp = safe_require.get("cmp", "autocomplete (nvim-cmp)")
local luasnip = safe_require.get("luasnip", "expansão de snippets")

if cmp and luasnip then
  safe_require("luasnip.loaders.from_vscode", function(loader)
    loader.lazy_load()
  end, "snippets prontos (friendly-snippets)")

  -- Snippets Go customizados (09/09/2026) — friendly-snippets não
  -- cobre Go nenhum (conferido no pacote antes de escrever isso).
  -- Ver lua/martini/snippets/go.lua pro conteúdo real.
  safe_require("luasnip.loaders.from_lua", function(loader)
    loader.load({ paths = vim.fn.stdpath("config") .. "/lua/martini/snippets" })
  end, "snippets Go customizados (iferr, forr, main, test, struct)")

  local cmp_nvim_lsp = safe_require.get("cmp_nvim_lsp", "capabilities de LSP pro autocomplete")
  if cmp_nvim_lsp then
    local capabilities = cmp_nvim_lsp.default_capabilities()
    vim.lsp.config["*"] = { capabilities = capabilities }
  end

  cmp.setup({
    snippet = {
      expand = function(args) luasnip.lsp_expand(args.body) end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<C-d>"] = cmp.mapping.scroll_docs(4),
      ["<C-u>"] = cmp.mapping.scroll_docs(-4),
      ["<Down>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end, { "i" }),
      ["<Up>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end, { "i" }),
      -- <Tab> genérico REMOVIDO daqui (26/09/2026) — ver nota
      -- "TABOUT" no topo do arquivo. Fora dos filetypes de Emmet,
      -- quem cuida do <Tab> agora é tabout.nvim (plugins/tabout.lua).
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end, { "i" }),
      ["<C-j>"] = cmp.mapping(function(fallback)
        if luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<C-k>"] = cmp.mapping(function(fallback)
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    }),
    sources = cmp.config.sources({
      { name = "luasnip", priority = 1000 },
      { name = "nvim_lsp", priority = 750 },
      { name = "buffer", priority = 500 },
    }),
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
  })

  safe_require("nvim-autopairs.completion.cmp", function(autopairs_cmp)
    cmp.event:on("confirm_done", autopairs_cmp.on_confirm_done())
  end, "fechar par automaticamente ao confirmar item do autocomplete")

  -- <Tab> LOCAL AO BUFFER pros filetypes de Emmet (26/09/2026) — ver
  -- nota "TABOUT" no topo do arquivo. Mapeamento por buffer (não
  -- global) tem prioridade sobre o <Tab> global do tabout.nvim, então
  -- nesses 5 filetypes o comportamento continua: menu do cmp visível
  -- → navega; senão → expande Emmet.
  local emmet_filetypes = { "html", "css", "scss", "jsx", "tsx" }
  vim.api.nvim_create_autocmd("FileType", {
    pattern = emmet_filetypes,
    callback = function(args)
      vim.keymap.set("i", "<Tab>", function()
        if cmp.visible() then
          cmp.select_next_item()
        else
          vim.schedule(function()
            vim.fn.feedkeys(
              vim.api.nvim_replace_termcodes("<plug>(emmet-expand-abbr)", true, false, true), ""
            )
          end)
        end
      end, { buffer = args.buf, desc = "cmp: próximo item, ou expandir Emmet" })
    end,
  })
end
