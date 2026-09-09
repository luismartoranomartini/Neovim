-- =========================================================
-- lua/martini/config/tabline.lua
-- Tabline nativa customizada — lista BUFFERS abertos (estilo aba de
-- navegador), não tabpages. SEM plugin: só a opção nativa 'tabline'
-- (:h 'tabline') apontando pra uma função Lua via v:lua.
--
-- POR QUE NÃO bufferline.nvim: decisão explícita (09/09/2026) — ficar
-- sem dependência nova, só com o que a própria API do Neovim já
-- oferece. Custo: sem ícone de arquivo, sem cor por diagnóstico LSP
-- — só nome do arquivo, indicador de modificado (●) e clique do
-- mouse pra trocar/fechar buffer.
--
-- CLIQUE DO MOUSE: sintaxe %{N}@FuncName@label%X (:h 'statusline',
-- item "@"). N vira o 1º argumento (minwid) da função quando você
-- clica — aqui, o número do buffer. v:lua.MartiniTabLineClick chama
-- direto a função Lua global abaixo, sem precisar de função
-- Vimscript intermediária.
--   - clique ESQUERDO: troca pro buffer
--   - clique DO MEIO: fecha o buffer (:bd) — mesmo padrão de fechar
--     aba com o botão do meio em qualquer editor com abas
--
-- showtabline = 2: sempre visível, mesmo com 1 buffer só — sem isso
-- a tabline nativa só aparece com 2+ tabPAGES (não bufferS), que não
-- é o que queremos aqui.
--
-- ATENÇÃO — tensão com <leader>n/<leader>w (config/keymaps.lua):
-- essa tabline mostra BUFFERS, não tabpages. <leader>n continua
-- criando uma tabpage nativa de verdade (:tabnew), mas a lista aqui
-- não se reorganiza por tabpage — ela mostra os mesmos buffers
-- abertos, independente de em qual tabpage você está. Ou seja,
-- <leader>n/<leader>w continuam funcionando mecanicamente, mas não
-- geram mais uma "aba nova" visualmente aqui. Ver conversa: decidir
-- se remove/repensa esses dois depois.
-- =========================================================

local function nome_curto(bufnr)
  local nome = vim.api.nvim_buf_get_name(bufnr)
  if nome == "" then return "[sem nome]" end
  return vim.fn.fnamemodify(nome, ":t")
end

local function render()
  local atual = vim.api.nvim_get_current_buf()
  local partes = {}

  for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    local grupo = (buf.bufnr == atual) and "%#MartiniTabLineSel#" or "%#MartiniTabLine#"
    local nome = nome_curto(buf.bufnr)
    local modificado = (buf.changed == 1) and " ●" or ""

    table.insert(partes, string.format(
      "%s %%%d@v:lua.MartiniTabLineClick@ %s%s %%X",
      grupo, buf.bufnr, nome, modificado
    ))
  end

  table.insert(partes, "%#MartiniTabLineFill#")
  return table.concat(partes)
end

-- Handler de clique (ver nota "CLIQUE DO MOUSE" acima). Assinatura
-- exigida pelo próprio Neovim: (minwid, clicks, button, modifiers).
-- minwid aqui é o número do buffer (ver %{N}@ na render() acima).
function _G.MartiniTabLineClick(bufnr, _, botao)
  if botao == "m" then
    vim.cmd("bd " .. bufnr)
  else
    vim.api.nvim_set_current_buf(bufnr)
  end
end

-- Precisa ser global (_G) — 'tabline' é avaliado via v:lua, que só
-- alcança funções Lua expostas globalmente, não locais do módulo.
_G.MartiniTabLineRender = render

vim.o.showtabline = 2
vim.o.tabline = "%!v:lua.MartiniTabLineRender()"
