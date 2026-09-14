# Atalhos — gerado automaticamente

Gerado por `:MartiniDocKeymaps` a partir dos keymaps GLOBAIS registrados em runtime (`vim.api.nvim_get_keymap`), não editado à mão. Só inclui atalhos com `desc` preenchido.

Keymaps buffer-local (LSP: `gd`/`K`/`[d`/`]d`/`<leader>fr`/`<leader>fu`; internos do oil: `g?`/`-`/`<CR>`) não aparecem aqui — continuam documentados à mão no README.

## Modo Normal

| Atalho | Ação |
|---|---|
| ` bd` | Fechar buffer |
| ` bx` | Fechar buffer (forçado) |
| ` db` | Debug: breakpoint (linha atual) |
| ` dc` | Debug: continuar / iniciar |
| ` di` | Debug: passo para dentro |
| ` dk` | Debug: passo para fora |
| ` do` | Debug: passo sobre |
| ` dr` | Debug: abrir REPL |
| ` dt` | Debug: encerrar sessão |
| ` du` | Debug: interface visual |
| ` dx` | Debug: limpar TODOS os breakpoints |
| ` e` | Explorador de arquivos (oil) |
| ` fd` | Find: abrir dashboard |
| ` fe` | Find: explorador de arquivos (oil, split vertical) |
| ` fn` | Find: novo arquivo (com mkdir -p) |
| ` ga` | Go: testar projeto inteiro |
| ` gr` | Go: testar apenas a função de teste sob o cursor |
| ` gt` | Go: testar pacote atual |
| ` ha` | HTTP: enviar todas as requisições do arquivo |
| ` hb` | HTTP: abrir scratchpad |
| ` hc` | HTTP: copiar requisição como comando curl |
| ` hn` | HTTP: próxima requisição |
| ` hp` | HTTP: requisição anterior |
| ` hq` | HTTP: fechar janela de resposta |
| ` hs` | HTTP: enviar requisição sob o cursor |
| ` ma` | Multicursor: selecionar todas ocorrencias |
| ` mh` | Multicursor: cursor principal anterior |
| ` mj` | Multicursor: pular linha abaixo |
| ` mk` | Multicursor: pular linha acima |
| ` ml` | Multicursor: proximo cursor principal |
| ` mn` | Multicursor: proxima ocorrencia |
| ` mp` | Multicursor: ocorrencia anterior |
| ` mq` | Multicursor: ativar/desativar cursores |
| ` ms` | Multicursor: pular proxima ocorrencia |
| ` msp` | Multicursor: pular ocorrencia anterior |
| ` mx` | Multicursor: remover cursor |
| ` n` | Nova tabpage |
| ` r` | Executar arquivo atual |
| ` rp` | Executar projeto |
| ` t` | Abrir terminal (split horizontal) |
| ` vs` | Abrir terminal (split vertical) |
| ` w` | Fechar aba atual |
| `&` | :help &-default |
| `<C-Down>` | Multicursor: cursor abaixo |
| `<C-G>` | fzf: buscar texto (grep) no projeto |
| `<C-L>` | :help CTRL-L-default |
| `<C-P>` | fzf: buscar arquivos pelo nome |
| `<C-T>` | Toggle terminal |
| `<C-Up>` | Multicursor: cursor acima |
| `<C-W><C-D>` | Show diagnostics under the cursor |
| `<C-W>d` | Show diagnostics under the cursor |
| `<F10>` | Debug: passo sobre (step over) |
| `<F11>` | Debug: passo para dentro (step into) |
| `<F12>` | Debug: passo para fora (step out) |
| `<F5>` | Debug: continuar / iniciar |
| `<Plug>(nvim-surround-change)` | Change a surrounding pair |
| `<Plug>(nvim-surround-change-line)` | Change a surrounding pair, putting replacements on new lines |
| `<Plug>(nvim-surround-delete)` | Delete a surrounding pair |
| `<Plug>(nvim-surround-normal)` | Add a surrounding pair around a motion (normal mode) |
| `<Plug>(nvim-surround-normal-cur)` | Add a surrounding pair around the current line (normal mode) |
| `<Plug>(nvim-surround-normal-cur-line)` | Add a surrounding pair around the current line, on new lines (normal mode) |
| `<Plug>(nvim-surround-normal-line)` | Add a surrounding pair around a motion, on new lines (normal mode) |
| `<Plug>luasnip-delete-check` | LuaSnip: Removes current snippet from jumplist |
| `<Plug>luasnip-expand-repeat` | LuaSnip: Repeat last node expansion |
| `Y` | :help Y-default |
| `[ ` | Add empty line above cursor |
| `[<C-L>` | :lpfile |
| `[<C-Q>` | :cpfile |
| `[<C-T>` | :ptprevious |
| `[A` | :rewind |
| `[B` | :brewind |
| `[D` | Jump to the first diagnostic in the current buffer |
| `[L` | :lrewind |
| `[Q` | :crewind |
| `[T` | :trewind |
| `[a` | :previous |
| `[b` | Buffer anterior |
| `[c` | Struct/class anterior |
| `[d` | Jump to the previous diagnostic in the current buffer |
| `[f` | Função anterior |
| `[l` | :lprevious |
| `[q` | :cprevious |
| `[t` | :tprevious |
| `] ` | Add empty line below cursor |
| `]<C-L>` | :lnfile |
| `]<C-Q>` | :cnfile |
| `]<C-T>` | :ptnext |
| `]A` | :last |
| `]B` | :blast |
| `]D` | Jump to the last diagnostic in the current buffer |
| `]L` | :llast |
| `]Q` | :clast |
| `]T` | :tlast |
| `]a` | :next |
| `]b` | Próximo buffer |
| `]c` | Próxima struct/class |
| `]d` | Jump to the next diagnostic in the current buffer |
| `]f` | Próxima função |
| `]l` | :lnext |
| `]q` | :cnext |
| `]t` | :tnext |
| `cS` | Change a surrounding pair, putting replacements on new lines |
| `cs` | Change a surrounding pair |
| `ds` | Delete a surrounding pair |
| `gO` | vim.lsp.buf.document_symbol() |
| `gc` | Toggle comment |
| `gcc` | Toggle comment line |
| `gf` | Criar/Abrir arquivo sob o cursor (relativo à pasta atual) |
| `gra` | vim.lsp.buf.code_action() |
| `gri` | vim.lsp.buf.implementation() |
| `grn` | vim.lsp.buf.rename() |
| `grr` | vim.lsp.buf.references() |
| `grt` | vim.lsp.buf.type_definition() |
| `grx` | vim.lsp.codelens.run() |
| `gx` | Opens filepath or URI under cursor with the system handler (file explorer, web browser, …) |
| `yS` | Add a surrounding pair around a motion, on new lines (normal mode) |
| `ySS` | Add a surrounding pair around the current line, on new lines (normal mode) |
| `ys` | Add a surrounding pair around a motion (normal mode) |
| `yss` | Add a surrounding pair around the current line (normal mode) |

## Modo Inserção

| Atalho | Ação |
|---|---|
| `<C-D>` | cmp.utils.keymap.set_map |
| `<C-E>` | cmp.utils.keymap.set_map |
| `<C-G>S` | Add a surrounding pair around the cursor, on new lines (insert mode) |
| `<C-G>s` | Add a surrounding pair around the cursor (insert mode) |
| `<C-N>` | cmp.utils.keymap.set_map |
| `<C-P>` | cmp.utils.keymap.set_map |
| `<C-S>` | vim.lsp.buf.signature_help() |
| `<C-Space>` | cmp.utils.keymap.set_map |
| `<C-U>` | cmp.utils.keymap.set_map |
| `<C-W>` | :help i_CTRL-W-default |
| `<C-Y>` | cmp.utils.keymap.set_map |
| `<CR>` | cmp.utils.keymap.set_map |
| `<Down>` | cmp.utils.keymap.set_map |
| `<Plug>(cmp.u.k.fallback_expr:<CR>)` | cmp.utils.keymap.set_map |
| `<Plug>(nvim-surround-insert)` | Add a surrounding pair around the cursor (insert mode) |
| `<Plug>(nvim-surround-insert-line)` | Add a surrounding pair around the cursor, on new lines (insert mode) |
| `<Plug>luasnip-delete-check` | LuaSnip: Removes current snippet from jumplist |
| `<Plug>luasnip-expand-or-jump` | LuaSnip: Expand or jump in the current snippet |
| `<Plug>luasnip-expand-repeat` | LuaSnip: Repeat last node expansion |
| `<Plug>luasnip-expand-snippet` | LuaSnip: Expand the current snippet |
| `<Plug>luasnip-jump-next` | LuaSnip: Jump to the next node |
| `<Plug>luasnip-jump-prev` | LuaSnip: Jump to the previous node |
| `<Plug>luasnip-next-choice` | LuaSnip: Change to the next choice from the choiceNode |
| `<Plug>luasnip-prev-choice` | LuaSnip: Change to the previous choice from the choiceNode |
| `<S-Tab>` | cmp.utils.keymap.set_map |
| `<Tab>` | cmp.utils.keymap.set_map |
| `<Up>` | cmp.utils.keymap.set_map |

## Modo Visual

| Atalho | Ação |
|---|---|
| ` ma` | Multicursor: selecionar todas ocorrencias |
| ` mh` | Multicursor: cursor principal anterior |
| ` mj` | Multicursor: pular linha abaixo |
| ` mk` | Multicursor: pular linha acima |
| ` ml` | Multicursor: proximo cursor principal |
| ` mn` | Multicursor: proxima ocorrencia |
| ` mp` | Multicursor: ocorrencia anterior |
| ` mq` | Multicursor: ativar/desativar cursores |
| ` ms` | Multicursor: pular proxima ocorrencia |
| ` msp` | Multicursor: pular ocorrencia anterior |
| ` mx` | Multicursor: remover cursor |
| `#` | :help v_#-default |
| `*` | :help v_star-default |
| `<C-Down>` | Multicursor: cursor abaixo |
| `<C-S>` | vim.lsp.buf.signature_help() |
| `<C-Up>` | Multicursor: cursor acima |
| `<Plug>(nvim-surround-visual)` | Add a surrounding pair around a visual selection |
| `<Plug>(nvim-surround-visual-line)` | Add a surrounding pair around a visual selection, on new lines |
| `<Plug>luasnip-expand-or-jump` | LuaSnip: Expand or jump in the current snippet |
| `<Plug>luasnip-expand-repeat` | LuaSnip: Repeat last node expansion |
| `<Plug>luasnip-expand-snippet` | LuaSnip: Expand the current snippet |
| `<Plug>luasnip-jump-next` | LuaSnip: Jump to the next node |
| `<Plug>luasnip-jump-prev` | LuaSnip: Jump to the previous node |
| `<Plug>luasnip-next-choice` | LuaSnip: Change to the next choice from the choiceNode |
| `<Plug>luasnip-prev-choice` | LuaSnip: Change to the previous choice from the choiceNode |
| `<S-Tab>` | cmp.utils.keymap.set_map |
| `<Tab>` | cmp.utils.keymap.set_map |
| `@` | :help v_@-default |
| `Q` | :help v_Q-default |
| `S` | Add a surrounding pair around a visual selection |
| `[N` | Select previous sibling node |
| `[c` | Struct/class anterior |
| `[f` | Função anterior |
| `[n` | Select previous node |
| `]N` | Select next sibling node |
| `]c` | Próxima struct/class |
| `]f` | Próxima função |
| `]n` | Select next node |
| `aa` | Selecionar parâmetro (outer) |
| `ac` | Selecionar struct/class (outer) |
| `af` | Selecionar função (outer) |
| `an` | Select parent (outer) node |
| `gS` | Add a surrounding pair around a visual selection, on new lines |
| `gc` | Toggle comment |
| `gra` | vim.lsp.buf.code_action() |
| `gx` | Opens filepath or URI under cursor with the system handler (file explorer, web browser, …) |
| `ia` | Selecionar parâmetro (inner) |
| `ic` | Selecionar struct/class (inner) |
| `if` | Selecionar função (inner) |
| `in` | Select child (inner) node |

## Modo Terminal

| Atalho | Ação |
|---|---|
| `<C-Q>` | Fechar terminal |
| `<C-T>` | Fechar terminal com Ctrl+t |
| `<C-W>` | Navegar splits de dentro do terminal |
| `<Esc>` | Sair do modo terminal |
