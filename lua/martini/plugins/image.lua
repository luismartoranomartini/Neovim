-- =========================================================
-- lua/martini/plugins/image.lua
-- Imagem de verdade dentro do Neovim (3rd/image.nvim), via protocolo
-- gráfico do Kitty. CONFIRMADO funcionando no seu Ghostty — testado
-- isolado (nvim --clean + minimal-setup.lua) antes de integrar aqui,
-- já que a documentação do próprio plugin não confirma suporte a
-- Ghostty especificamente ("not that much information about this
-- yet"). Diferente da tentativa com chafa no dashboard (que rodava
-- dentro do :terminal embutido, sem suporte ao protocolo): esse
-- plugin escreve a sequência gráfica direto pro terminal real, via
-- janela flutuante posicionada sobre o buffer — não passa pelo
-- terminal virtual, por isso funciona.
--
-- processor = "magick_cli": chama o ImageMagick (já instalado, ver
-- health.lua) via linha de comando pra redimensionar/cortar/
-- converter — mais simples que a alternativa (magick_rock), que
-- precisa de LuaRocks configurado à parte. Sem isso configurado,
-- magick_cli é a única opção viável sem trabalho extra.
--
-- Integrações padrão da lib mantidas como estão (markdown, asciidoc,
-- neorg, rst, typst) — cobre os manuscritos/anotações em Markdown
-- que você já usa. html/css ficam desligadas (padrão da lib) — não
-- pedido, e ligar teria custo (a lib teria que varrer HTML/CSS atrás
-- de referência de imagem toda vez que o buffer mudasse).
--
-- hijack_file_patterns (padrão da lib, mantido): abrir um .png/.jpg/
-- etc. direto (inclusive navegando pelo oil) já renderiza a imagem
-- em vez de mostrar o conteúdo binário como texto.
-- =========================================================

local safe_require = require("martini.utils.safe_require")

safe_require("image", function(image)
  image.setup({
    backend = "kitty",
    processor = "magick_cli",
  })
end, "renderização de imagem real dentro do Neovim (arquivos .png/.jpg, imagens em Markdown)")
