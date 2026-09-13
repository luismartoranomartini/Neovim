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
-- USO (em qualquer plugins/*.lua):
--   local safe_require = require("martini.utils.safe_require")
--
--   safe_require("nvim-autopairs", function(nvim_autopairs)
--     nvim_autopairs.setup({ check_ts = true })
--   end, "fecha parênteses/aspas automaticamente ao digitar")
--
-- O 3º argumento é uma frase curta e livre descrevendo o IMPACTO pro
-- usuário se o plugin faltar — não o nome técnico de novo, que já
-- está no 1º argumento.
-- =========================================================

local function safe_require(nome_modulo, callback, funcionalidade)
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

  local ok_setup, erro_setup = pcall(callback, modulo_ou_erro)
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

  return modulo_ou_erro
end

return safe_require
