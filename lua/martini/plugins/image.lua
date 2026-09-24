-- =========================================================
-- lua/martini/plugins/image.lua
-- 3rd/image.nvim — renderização de imagem dentro do buffer via
-- protocolo gráfico da Kitty (também suportado nativamente pelo
-- WezTerm, ver nota "VOLTA" em lazy.lua).
--
-- REQUISITO DE SISTEMA: ImageMagick precisa estar instalado
-- separadamente (não é gerenciado pelo lazy.nvim) — `sudo pacman -S
-- imagemagick` no Arch. Sem isso, o plugin carrega mas falha ao
-- tentar renderizar qualquer imagem.
--
-- backend = "kitty": funciona tanto no terminal Kitty quanto no
-- WezTerm (que implementa o mesmo protocolo gráfico), confirmado
-- antes de reativar este plugin.
-- =========================================================
local safe_require = require("martini.utils.safe_require")

safe_require("image", function(image)
  image.setup({
    backend = "kitty",
    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = false,
        download_remote_images = true,
        only_render_image_at_cursor = false,
      },
    },
    -- Abre arquivos de imagem diretamente como imagem renderizada,
    -- em vez de conteúdo binário ilegível no buffer.
    hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" },
  })
end, "renderização de imagem no buffer (image.nvim)")
