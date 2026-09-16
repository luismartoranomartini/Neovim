-- =========================================================
-- lua/martini/utils/terminal.lua
-- Funções de terminal usadas por config/keymaps.lua e
-- plugins/dashboard.lua (item "Terminal" do menu).
--
-- REAPROVEITAMENTO (09/09/2026): antes, toda chamada de
-- open_horizontal/open_vertical criava um buffer de terminal NOVO
-- (processo de shell novo), mesmo que já existisse um aberto em
-- algum lugar — visível ou escondido atrás de outra janela. Isso
-- acumulava processos de shell à toa, e foi a causa real do "preciso
-- apertar t duas vezes" no dashboard: o toggle() fechava um terminal
-- escondido de sobra na primeira tecla, só abrindo um novo na
-- segunda.
--
-- Agora: find_terminal() procura um terminal já existente (primeiro
-- visível numa janela; se não achar visível, o primeiro buffer de
-- terminal carregado, mesmo escondido) ANTES de criar um novo. Só
-- cria buffer/processo novo se não existir nenhum.
-- =========================================================

local M = {}

-- Procura um terminal existente. Retorna (bufnr, winid) se já estiver
-- visível em alguma janela, ou (bufnr, nil) se existir mas estiver
-- escondido, ou (nil, nil) se não existir nenhum.
local function find_terminal()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      return buf, win
    end
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" and vim.api.nvim_buf_is_loaded(buf) then
      return buf, nil
    end
  end
  return nil, nil
end

-- <leader>t — terminal horizontal embaixo, altura fixa 15. Reaproveita
-- um terminal existente (focando a janela se já visível, ou abrindo
-- o buffer existente num split novo se estiver escondido); só cria
-- processo de shell novo se não existir nenhum terminal ainda.
function M.open_horizontal()
  local buf, win = find_terminal()
  if win then
    vim.api.nvim_set_current_win(win)
  elseif buf then
    vim.cmd("botright split | resize 15")
    vim.api.nvim_win_set_buf(0, buf)
  else
    vim.cmd("botright split | resize 15 | terminal")
  end
  vim.cmd("startinsert")
end

-- <leader>vs — mesma lógica de reaproveitamento acima, só muda o
-- split (vertical, lado a lado) quando precisa abrir um novo.
function M.open_vertical()
  local buf, win = find_terminal()
  if win then
    vim.api.nvim_set_current_win(win)
  elseif buf then
    vim.cmd("vsplit")
    vim.api.nvim_win_set_buf(0, buf)
  else
    vim.cmd("vsplit | terminal")
  end
  vim.cmd("startinsert")
end

-- Ctrl-t — alterna: fecha o terminal se algum estiver visível em
-- qualquer janela, senão abre (reaproveitando terminal escondido, se
-- houver — ver open_horizontal acima).
function M.toggle()
  local _, win = find_terminal()
  if win then
    vim.api.nvim_win_close(win, false)
    return
  end
  M.open_horizontal()
end

return M
