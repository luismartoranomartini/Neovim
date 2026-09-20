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
-- instalado fora desses filetypes). Antes, <Tab> tentava expandir
-- Emmet em QUALQUER buffer (Go, Lua, etc.), sem efeito nenhum — o
-- <plug>(emmet-expand-abbr) não fazia nada porque o emmet nem estava
-- instalado ali, e o <Tab> normal (indentar) ficava perdido. Fora
-- desses 5 filetypes, <Tab> agora cai no fallback() — comportamento
-- nativo do Neovim. LISTA DUPLICADA de propósito (mesma de
-- editing.lua): são 5 nomes, não vale a pena um módulo compartilhado
-- só pra isso — se mudar uma lista, mudar a outra também.
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
      -- Mesma lista de filetypes do :EmmetInstall em editing.lua —
      -- ver nota no topo do arquivo.
      ["<Tab>"] = cmp.mapping(function(fallback)
        local emmet_filetypes = {
          html = true, css = true, scss = true, jsx = true, tsx = true,
        }
        if emmet_filetypes[vim.bo.filetype] then
          if cmp.visible() then cmp.close() end
          vim.schedule(function()
            vim.fn.feedkeys(
              vim.api.nvim_replace_termcodes("<plug>(emmet-expand-abbr)", true, false, true), ""
            )
          end)
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
end
