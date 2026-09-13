-- =========================================================
-- lua/martini/utils/safe_require.lua
-- Substitui o padrão pcall(function() require("x").setup(...) end)
-- mudo, espalhado por vários plugins/*.lua — se o require ou o
-- setup() falhassem, o erro era engolido sem dizer QUAL plugin
-- falhou nem O QUE deixou de funcionar (ver revisão do repositório,
-- item 2: "falhar de forma visível quando um plugin obrigatório não
-- estiver instalado").
--
-- Distingue os dois casos possíveis, com mensagem diferente pra cada:
--   1. Módulo não encontrado (plugin não instalado) — provável causa:
--      lazy.nvim ainda não terminou de clonar, ou faltou rodar
--      :Lazy install depois de adicionar o plugin à lista.
--   2. Módulo encontrado, mas setup() deu erro — plugin instalado,
--      configuração (a função de callback) é que tem problema.
--
-- DUAS FORMAS DE USO:
--
--   1. safe_require(nome, callback, funcionalidade) — require + setup
--      imediato. Uso mais comum (ver plugins/editing.lua, format.lua,
--      finder.lua, etc.):
--
--        local safe_require = require("martini.utils.safe_require")
--        safe_require("nvim-autopairs", function(nvim_autopairs)
--          nvim_autopairs.setup({ check_ts = true })
--        end, "fecha parênteses/aspas automaticamente ao digitar")
--
--   2. safe_require.get(nome, funcionalidade) — só busca o módulo e
--      devolve (ou nil, já notificando), sem chamar setup nenhum.
--      Útil quando o resto do arquivo precisa decidir o que fazer
--      com o módulo depois (ver plugins/completion.lua,
--      textobjects.lua):
--
--        local cmp = safe_require.get("cmp", "autocomplete")
--        if cmp then cmp.setup({...}) end
--
-- O último argumento (funcionalidade) é sempre uma frase curta e
-- livre descrevendo o IMPACTO pro usuário se o plugin faltar — não o
-- nome técnico de novo, que já está no 1º argumento.
-- =========================================================

local M = {}

---@param nome_modulo string
---@param funcionalidade? string
---@return any|nil
function M.get(nome_modulo, funcionalidade)
  local descricao = funcionalidade or "uma funcionalidade"

  local ok_require, modulo_ou_erro = pcall(require, nome_modulo)
  if not ok_require then
    vim.notify(
      string.format(
        "martini.nvim: plugin '%s' não encontrado — %s não vai funcionar.\nRode :Lazy install e reinicie o Neovim.",
        nome_modulo,
        descricao
      ),
      vim.log.levels.WARN
    )
    return nil
  end

  return modulo_ou_erro
end

---@param nome_modulo string
---@param callback fun(modulo: any)
---@param funcionalidade? string
---@return any|nil
function M.setup(nome_modulo, callback, funcionalidade)
  local descricao = funcionalidade or "uma funcionalidade"

  local modulo = M.get(nome_modulo, descricao)
  if not modulo then return nil end

  local ok_setup, erro_setup = pcall(callback, modulo)
  if not ok_setup then
    vim.notify(
      string.format(
        "martini.nvim: '%s' está instalado, mas o setup() falhou — %s pode não funcionar direito.\nErro: %s",
        nome_modulo,
        descricao,
        tostring(erro_setup)
      ),
      vim.log.levels.WARN
    )
    return nil
  end

  return modulo
end

-- Torna M chamável diretamente: safe_require(nome, callback, desc) ==
-- safe_require.setup(nome, callback, desc). Mantém compatível o uso
-- que já foi aplicado em plugins/editing.lua antes de M.get existir.
setmetatable(M, {
  __call = function(_, ...) return M.setup(...) end,
})

return M
