set noswapfile
"set guicursor=

call plug#begin('~/.vim/plugged')
Plug 'prabirshrestha/async.vim'
Plug 'neovim/nvim-lspconfig'
"Plug 'prabirshrestha/vim-lsp'
"Plug 'ajh17/vimcompletesme'
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

"if executable('clangd')
"    augroup lsp_clangd
"        autocmd!
"        autocmd User lsp_setup call lsp#register_server({
"                    \ 'name': 'clangd',
"                    \ 'cmd': {server_info->['clangd']},
"                    \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
"                    \ })
"        autocmd FileType c setlocal omnifunc=lsp#complete
"        autocmd FileType cpp setlocal omnifunc=lsp#complete
"        autocmd FileType objc setlocal omnifunc=lsp#complete
"        autocmd FileType objcpp setlocal omnifunc=lsp#complete
"        autocmd FileType * let b:vcm_tab_complete = "omni"
"    augroup end
"endif

set clipboard^=unnamed
set mouse=a
set number
set ts=4 ss=4 sw=4 et
set autoindent smartindent cindent

map <leader>w :tabn<CR>
map <leader>q :tabN<CR>

let g:mapleader = ","

au BufWritePost ~/.nvimrc source ~/.nvimrc


if !exists("g:_vimrc_loaded_once")
    let base16colorspace=256
    set termguicolors
    colorscheme base16-default-dark
    let g:airline#extensions#tabline#buffer_idx_mode = 1
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#show_buffers = 1
    let g:airline#extensions#tabline#tab_nr_type = 1 " tab number
    let g:airline_powerline_fonts=1
    let g:airline#extensions#bufferline#enabled = 1
    let g:airline#extensions#tmuxline#enabled = 1
    "let g:airline_theme='wombat'
    let g:SuperTabDefaultCompletionType = "context"
    let g:_vimrc_loaded_once = 1
endif

" tell complete to look in the dictionary
set complete-=k complete+=k

" load the dictionary according to syntax
:au BufReadPost * if exists("b:current_syntax")
:au BufReadPost * let &dictionary = substitute("C:\\vim\\vimfiles\\dict\\FT.dict", "FT", b:current_syntax, "")
:au BufReadPost * endif
 
function! InsertQuote(q)
  let col = col('.')
  let char = getline('.')[col - 1]
  if char == a:q
      return "\<right>"
  else
      return a:q . a:q . "\<left>"
  endif 
endfunction

function! InsertBracket(open, close)
  let col = col('.')
  let char = getline('.')[col - 1]
  if char && char !~ " "
      return a:open
  else
      return a:open . a:close . "\<left>"
  endif 
endfunction


function! InsertClosingBracket(brack)
  let col = col('.')
  let char = getline('.')[col - 1]
  if char == a:brack
      return "\<right>"
  else
      return a:brack
  endif 
endfunction

function SmartBackspace()
  let col = col('.')
  let char = getline('.')[col - 1]
  if getline('.')[col - 2] =~ "[\[({]" && getline('.')[col - 1] =~ "[\])}]"
      return "\<right>\<backspace>\<backspace>"
  else
      return "\<backspace>"
  endif 
endfunction

" Autoclose brackets
function! ToggleAutoClose()
    if mapcheck("'", "i") != ""
        :iunmap "
        :iunmap '
        :iunmap (
        :iunmap [
        :iunmap {
        :iunmap {<CR>
        :iunmap {;<CR>
        :iunmap )
        :iunmap ]
        :iunmap }
        :iunmap <backspace>
        echo "autoclose off"
    else
        :inoremap <expr> " InsertQuote ("\"")
        :inoremap <expr> ' InsertQuote ("'")
        :inoremap <expr> ( InsertBracket('(', ')')
        :inoremap <expr> [ InsertBracket('[', ']')
        :inoremap <expr> { InsertBracket('{', '}')
        :inoremap <nowait> {<CR> {<CR>}<ESC>O
        :inoremap <nowait> {;<CR> {<CR>};<ESC>O
        :inoremap <expr> ) InsertClosingBracket (")")
        :inoremap <expr> ] InsertClosingBracket ("]")
        :inoremap <expr> } InsertClosingBracket ("}")
        :inoremap <expr> <backspace> SmartBackspace()
        echo "autoclose on"
    endif
endfunction

if !exists("g:_vimrc_loaded_once")
    exec ToggleAutoClose() | redraw
endif
map <expr> <Leader>ac ToggleAutoClose()


"command! W :execute ':silent w !sudo tee % > /dev/null' | :edit!
cnoremap w!! w :term sudo tee % > /dev/null

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
"
" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif
"
" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

lua << EOF
local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

end
local servers = { 'rust_analyzer' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end
EOF
