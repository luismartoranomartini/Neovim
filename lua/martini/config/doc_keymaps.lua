-- =========================================================
-- lua/martini/config/doc_keymaps.lua
-- :MartiniDocKeymaps [caminho] — gera uma tabela markdown com todos
-- os atalhos GLOBAIS que têm `desc` preenchido, lendo direto da API
-- do Neovim (vim.api.nvim_get_keymap), não fazendo parsing de texto
-- dos arquivos .lua.
--
-- POR QUÊ ler da API em vez de grepar os arquivos: o texto fonte
-- muda de formato (chamada em uma linha, multi-linha, função
-- anônima, tabela de opções compartilhada) e qualquer parser de
-- texto quebra ou dá falso negativo nesses casos — foi exatamente
-- isso que aconteceu ao tentar auditar manualmente antes de escrever
-- este arquivo (vários keymaps pareciam "sem desc" num grep simples
-- só por estarem em outra linha). A API do Neovim já devolve
-- exatamente o que está registrado em runtime — a mesma verdade que
-- vale quando você aperta a tecla.
--
-- ESCOPO — só keymaps GLOBAIS (não buffer-local) com `desc`
-- preenchido:
--   - Cobre: tudo em config/keymaps.lua e os vim.keymap.set() sem
--     `buffer =` espalhados pelos plugins/*.lua e languages/*.lua
--     (ex.: <leader>e/<leader>fe em oil.lua, <leader>gt/ga/gr em
--     go.lua, <leader>h* em http.lua).
--   - NÃO cobre: keymaps BUFFER-LOCAL — os de LSP (gd, K, [d, ]d,
--     <leader>fr, <leader>fu, registrados dentro de LspAttach com
--     `buffer = args.buf`) e os internos do próprio oil.nvim (g?, -,
--     <CR>). nvim_get_keymap() só enxerga o escopo global; esses
--     dois grupos continuam documentados à mão, em prosa, no README
--     e no atalhos-martini.md — mesmo tratamento que já valia antes
--     deste gerador existir.
--
-- Se um keymap novo for criado sem `desc`, ele não aparece aqui —
-- sem erro, sem aviso. Efeito colateral aceito de propósito: força
-- sempre preencher `desc` pra um atalho "existir" na documentação.
-- =========================================================

local M = {}

local NOME_MODO = {
  n = "Normal",
  i = "Inserção",
  v = "Visual",
  t = "Terminal",
}

local MODOS = { "n", "i", "v", "t" }

---@param caminho_saida? string
function M.gerar(caminho_saida)
  caminho_saida = caminho_saida or (vim.fn.stdpath("config") .. "/ATALHOS-GERADO.md")

  local linhas = {
    "# Atalhos — gerado automaticamente",
    "",
    "Gerado por `:MartiniDocKeymaps` a partir dos keymaps GLOBAIS registrados em runtime (`vim.api.nvim_get_keymap`), não editado à mão. Só inclui atalhos com `desc` preenchido.",
    "",
    "Keymaps buffer-local (LSP: `gd`/`K`/`[d`/`]d`/`<leader>fr`/`<leader>fu`; internos do oil: `g?`/`-`/`<CR>`) não aparecem aqui — continuam documentados à mão no README.",
    "",
  }

  local total = 0

  for _, modo in ipairs(MODOS) do
    local mapas = vim.api.nvim_get_keymap(modo)
    local linhas_tabela = {}

    for _, km in ipairs(mapas) do
      if km.desc and km.desc ~= "" then
        table.insert(linhas_tabela, { tecla = km.lhs, desc = km.desc })
      end
    end

    if #linhas_tabela > 0 then
      table.sort(linhas_tabela, function(a, b) return a.tecla < b.tecla end)

      table.insert(linhas, "## Modo " .. (NOME_MODO[modo] or modo))
      table.insert(linhas, "")
      table.insert(linhas, "| Atalho | Ação |")
      table.insert(linhas, "|---|---|")
      for _, item in ipairs(linhas_tabela) do
        local tecla = item.tecla:gsub("|", "\\|")
        local desc = item.desc:gsub("|", "\\|")
        table.insert(linhas, string.format("| `%s` | %s |", tecla, desc))
        total = total + 1
      end
      table.insert(linhas, "")
    end
  end

  if total == 0 then
    vim.notify("MartiniDocKeymaps: nenhum keymap global com 'desc' encontrado.", vim.log.levels.WARN)
    return
  end

  local arquivo, erro_abertura = io.open(caminho_saida, "w")
  if not arquivo then
    vim.notify("MartiniDocKeymaps: não consegui escrever em " .. caminho_saida .. " (" .. tostring(erro_abertura) .. ")", vim.log.levels.ERROR)
    return
  end
  arquivo:write(table.concat(linhas, "\n"))
  arquivo:close()

  vim.notify("MartiniDocKeymaps: " .. total .. " atalhos escritos em " .. caminho_saida, vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("MartiniDocKeymaps", function(opts)
  local caminho = opts.args ~= "" and opts.args or nil
  M.gerar(caminho)
end, {
  nargs = "?",
  complete = "file",
  desc = "Gera tabela markdown dos atalhos globais a partir do runtime (opcional: caminho de saída)",
})

return M
