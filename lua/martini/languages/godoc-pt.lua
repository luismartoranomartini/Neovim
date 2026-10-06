-- =========================================================
-- lua/martini/languages/godoc-pt.lua
-- :GoDocPt [termo] — mostra a saída de `go doc -all` traduzida para
-- português (via translate-shell, comando `trans`) numa janela flutuante.
-- Sem argumento, usa o termo sob o cursor (aceita pacote.Função, ex.:
-- fmt.Println). Atalho: <leader>gk.
-- Requisitos: go e trans (Arch: sudo pacman -S translate-shell).
-- AVISO: o `trans` traduz TUDO, inclusive trechos de código dos
-- exemplos — nomes e comentários dentro deles podem sair alterados.
-- Mudanças em relação à versão original: roda de forma assíncrona (o
-- editor não trava durante a tradução), avisa se go/trans faltam, aceita
-- "pacote.Nome" sob o cursor e fecha a janela com q ou <Esc>.
-- =========================================================

local function abrir_janela(linhas)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, linhas)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].bufhidden = "wipe"

  local width = math.min(90, vim.o.columns - 4)
  local height = math.min(25, vim.o.lines - 4)
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
  })

  for _, tecla in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", tecla, "<cmd>close<cr>", { buffer = buf, silent = true })
  end
end

local function go_doc_pt(query)
  if not query or query == "" then
    -- <cWORD> pega "fmt.Println(" inteiro; o match descarta a pontuação.
    query = vim.fn.expand("<cWORD>"):match("[%w_%.]+") or ""
  end
  if query == "" then
    vim.notify("GoDocPt: nenhum termo sob o cursor", vim.log.levels.WARN)
    return
  end

  for _, exe in ipairs({ "go", "trans" }) do
    if vim.fn.executable(exe) == 0 then
      vim.notify("GoDocPt: '" .. exe .. "' não encontrado no PATH", vim.log.levels.ERROR)
      return
    end
  end

  vim.notify("GoDocPt: traduzindo " .. query .. " ...")
  -- O termo vai como parâmetro posicional ($1): sem problema de aspas.
  vim.system(
    { "sh", "-c", 'go doc -all "$1" 2>/dev/null | trans -b :pt', "sh", query },
    { text = true },
    vim.schedule_wrap(function(res)
      local texto = res.stdout or ""
      if texto:match("^%s*$") then
        vim.notify("Nenhuma documentação encontrada para: " .. query, vim.log.levels.WARN)
        return
      end
      abrir_janela(vim.split(texto, "\n"))
    end)
  )
end

vim.api.nvim_create_user_command("GoDocPt", function(opts)
  go_doc_pt(opts.args)
end, { nargs = "?", desc = "go doc traduzido para português" })

vim.keymap.set("n", "<leader>gk", function()
  go_doc_pt()
end, { desc = "Go: documentação em português (go doc + trans)" })
