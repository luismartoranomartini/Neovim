-- =========================================================
-- lua/martini/utils/type_highlight.lua
-- Colore tipos builtin (int, string, bool, etc.) com uma cor por
-- NOME LITERAL, usando o Treesitter de verdade (não regex/matchadd) —
-- só acerta nós que o parser classificou como tipo (predefined_type/
-- type_identifier), nunca nome de variável, comentário ou string.
--
-- register(filetype, query_string, mapa_cores)
--   filetype: filetype a observar (ex.: "go")
--   query_string: query Treesitter que captura os candidatos como @type
--   mapa_cores: { ["int"] = "TypeInt", ["string"] = "TypeString", ... }
--               nome literal do nó -> highlight group (definido em
--               colors.lua)
-- =========================================================

local M = {}

function M.register(filetype, query_string, mapa_cores)
  local ns = vim.api.nvim_create_namespace("martini_type_hl_" .. filetype)

  local function aplicar(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    if vim.bo[bufnr].filetype ~= filetype then return end

    local ok_parser, parser = pcall(vim.treesitter.get_parser, bufnr, filetype)
    if not ok_parser or not parser then return end

    local ok_query, query = pcall(vim.treesitter.query.parse, filetype, query_string)
    if not ok_query then return end

    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

    local tree = parser:parse()[1]
    if not tree then return end
    local root = tree:root()

    for _, node in query:iter_captures(root, bufnr, 0, -1) do
      local texto = vim.treesitter.get_node_text(node, bufnr)
      local grupo = mapa_cores[texto]
      if grupo then
        local srow, scol, erow, ecol = node:range()
        vim.api.nvim_buf_set_extmark(bufnr, ns, srow, scol, {
          end_row = erow,
          end_col = ecol,
          hl_group = grupo,
          priority = 200, -- acima do highlight semantico padrao
        })
      end
    end
  end

  vim.api.nvim_create_autocmd(
    { "FileType", "BufEnter", "TextChanged", "TextChangedI", "InsertLeave" },
    { callback = function(args) aplicar(args.buf) end }
  )
end

return M
