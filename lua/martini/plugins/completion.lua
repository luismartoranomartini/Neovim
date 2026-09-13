-- =========================================================
-- lua/martini/plugins/completion.lua
-- nvim-cmp + LuaSnip + capabilities LSP + integração com Emmet no Tab.
-- Carrega ANTES de plugins/lsp.lua: define vim.lsp.config["*"] com as
-- capabilities do cmp_nvim_lsp, que os servidores individuais herdam.
--
-- SAFE_REQUIRE (09/09/2026): pcalls mudos trocados por
-- utils/safe_require.lua — ver nota completa em plugins/editing.lua.
-- Usa safe_require.get() (não a forma chamável direta) porque cmp E
-- luasnip precisam estar presentes ANTES de decidir configurar
-- qualquer coisa — não dá pra fazer "setup imediato" de um sem saber
-- se o outro também existe.
-- =========================================================

local safe_require = require("martini.utils.safe_require")

-- Verifica se a posição atual tem uma abreviação Emmet válida
local emmet_fts = { html = true, css = true, scss = true, jsx = true, tsx = true, gotmpl = true }

local function emmet_expandable()
  if not emmet_fts[vim.bo.filetype] then return false end
  local col = vim.fn.col(".") - 1
  local before = vim.fn.getline("."):sub(1, col)
  return before:match("[%w%.#%[%]>%)%*]+$") ~= nil
end

local cmp = safe_require.get("cmp", "autocomplete (nvim-cmp)")
local luasnip = safe_require.get("luasnip", "expansão de snippets")

if cmp and luasnip then
  safe_require("luasnip.loaders.from_vscode", function(loader)
    loader.lazy_load()
  end, "snippets prontos (friendly-snippets)")

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
      -- emmet_expandable() é checado ANTES de cmp.visible(). Se o
      -- cursor está sobre uma abreviação Emmet válida, ela tem
      -- prioridade e o popup do cmp é fechado antes de expandir.
      ["<Tab>"] = cmp.mapping(function(fallback)
        if emmet_expandable() then
          if cmp.visible() then cmp.close() end
          vim.schedule(function()
            vim.fn.feedkeys(
              vim.api.nvim_replace_termcodes("<plug>(emmet-expand-abbr)", true, false, true), ""
            )
          end)
        elseif cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
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
