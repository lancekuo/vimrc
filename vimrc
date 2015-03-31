scriptencoding utf-8
set encoding=utf-8

set nocompatible
call pathogen#infect()
syntax on
filetype plugin indent on

if exists("g:did_load_filetypes")
    filetype off
    filetype plugin indent off
endif
" For CentOS
" set runtimepath+=/usr/lib/golang/misc/vim " replace $GOROOT with the output of: go env GOROOT
" For uBuntu
set runtimepath+=/usr/local/go/misc/vim " replace $GOROOT with the output of: go env GOROOT  "

" set leader to ,
let mapleader='\'
" let g:mapleader=","

set expandtab
set shiftwidth=4
set softtabstop=4
set laststatus=2
set nonumber
set nolist
" set listchars=trail:⋅,nbsp:⋅,tab:▷⋅
set listchars=trail:⋅,nbsp:⋅,tab:▸\ 
set nocursorline
" highlight CursorLine cterm=none ctermbg=4
" highlight OverLength ctermbg=red ctermfg=white guibg=#592929
" match OverLength /\%81v.\+/

map <silent> <F8> <Esc> :setlocal spell spelllang=en_us<CR>
map <silent> <F9> <Esc> :setlocal nospell<CR>
nmap <silent> <F1>      :NERDTreeToggle<CR>
" nmap <silent> <F5>      :make<CR>:copen 3<CR>
autocmd FileType go map <leader>t :call VimuxRunCommand("go test " . bufname("%"))<CR>
autocmd FileType go map <leader>r :call VimuxRunCommand("go run " . bufname("%"))<CR>
autocmd FileType go map <leader>i :call VimuxRunCommand("go install")<CR>
autocmd FileType go map <leader>b :call VimuxRunCommand("go build")<CR>
nnoremap th             :tabfirst<CR>
nnoremap tj             :tabnext<CR>
nnoremap tk             :tabprev<CR>
nnoremap tl             :tablast<CR>
nnoremap tt             :tabedit<Space>
nnoremap tm             :tabm<Space>
nnoremap tc             :tabclose<CR>
nnoremap tn             :tabnew<CR>

function! MyLastWindow()
" if the window is quickfix go on
  if &buftype=="quickfix"
" if this window is last on screen quit without warning
    if winbufnr(2) == -1
      quit!
    endif
  endif
  if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
endfunction

autocmd BufEnter * call MyLastWindow()
autocmd BufRead,BufNewFile *.md set filetype=markdown
" autocmd VimEnter * NERDTreeToggle
autocmd FileType go autocmd BufWritePre <buffer> Fmt
autocmd Filetype go set makeprg=go\ build
autocmd! BufWritePost .vimrc source %


" let g:airline_powerline_fonts = 1
highlight   clear
highlight   Pmenu         ctermfg=0 ctermbg=2
highlight   PmenuSel      ctermfg=0 ctermbg=7
highlight   PmenuSbar     ctermfg=7 ctermbg=0
highlight   PmenuThumb    ctermfg=0 ctermbg=7
highlight   Search cterm=NONE ctermfg=yellow ctermbg=red
highlight   Comment term=standout cterm=bold ctermfg=blue
" highlight   Normal ctermbg=black ctermfg=white
highlight   Folded ctermbg=black ctermfg=darkcyan
highlight   Cursor ctermbg=Gray ctermfg=Blue
highlight   clear SpellBad
highlight   SpellBad term=underline cterm=underline ctermfg=red
highlight   TabLine ctermbg=blue
highlight   TabLineFill ctermbg=green
highlight   TabLineSel ctermbg=red

let g:bufferline_echo = 0
let g:SuperTabDefaultCompletionType = "context"
let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
    \ }

" Specific filetype by file name
autocmd BufNewFile,BufRead Gemfile set filetype=ruby
autocmd BufNewFile,BufRead Vagrantfile set filetype=ruby
autocmd BufNewFile,BufRead Berksfile set filetype=ruby
autocmd BufNewFile,BufRead .vimrc set filetype=vim
