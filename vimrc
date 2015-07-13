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
" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
  " bind \ (backward slash) to grep shortcut
  command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
endif
set switchbuf+=usetab,newtab

colorscheme molokai
" let &colorcolumn="80,".join(range(120,999),",")
let &colorcolumn="80"

" let g:ctrlp_working_path_mode = 'ca'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/]\.(git|hg|svn)$',
    \ 'file': '\v\.(exe|so|dll)$',
    \ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
    \ }

autocmd FileType python,shell,coffee set commentstring=#\ %s

" Prevent flash close windows
set completeopt-=preview

" colorscheme solarized

" For CentOS
" set runtimepath+=/usr/lib/golang/misc/vim " replace $GOROOT with the output of: go env GOROOT
" For uBuntu
set runtimepath+=/usr/local/go/misc/vim " replace $GOROOT with the output of: go env GOROOT  "

" set leader to ,
let mapleader='\'
" let g:mapleader=","

" set nowrap
set textwidth=0
set expandtab
set shiftwidth=4
set softtabstop=4
set laststatus=2
set number
set nolist
set listchars=trail:⋅,nbsp:⋅,tab:▸\ 
set nocursorline

nmap <silent> <F1>       :NERDTreeToggle<CR>
nmap <silent> <F2>       :set paste!<CR>:set paste?<CR>
nmap <silent> <F3>       :set number!<CR>:set number?<CR>
nmap <silent> <F4>       :set invlist!<CR>:set invlist?<CR>
nmap <F5>                :AlignCtrl I= =
map  <silent> <F6>       :Align<CR>
map  <silent> <F7> <Esc> :TagbarToggle<CR>
map  <silent> <F8> <Esc> :setlocal spell spelllang=en_us<CR>
map  <silent> <F9> <Esc> :setlocal nospell<CR>
nnoremap K               :grep! "\b<C-R><C-W>\b"<CR>:botright cw<CR>
nnoremap th              :tabfirst<CR>
nnoremap tj              :tabnext<CR>
nnoremap tk              :tabprev<CR>
nnoremap tl              :tablast<CR>
nnoremap tt              :tabedit<Space>
nnoremap tm              :tabm<Space>
nnoremap tx              :tabclose<CR>
nnoremap tc              :tabnew<CR>

autocmd FileType go         map <leader>t :call VimuxRunCommand("go test " . bufname("%"))<CR>
autocmd FileType python     map <leader>t :call VimuxRunCommand("restart tellus-portal")<CR>
autocmd FileType go         map <leader>r :call VimuxRunCommand("go run " . bufname("%"))<CR>
autocmd FileType go         map <leader>i :call VimuxRunCommand("go install")<CR>
autocmd FileType go         map <leader>b :call VimuxRunCommand("go build")<CR>
autocmd FileType go         call SetGoOptions()
autocmd FileType python     call SetGoOptions()
autocmd FileType javascript call SetGoOptions()

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

function! SetGoOptions()
"    setlocal shiftwidth=4 tabstop=4 softtabstop=4 expandtab makeprg=php-xdebug\ %
     :call tagbar#autoopen(0)
endfunction

autocmd BufEnter * call MyLastWindow()
" autocmd VimEnter * NERDTreeToggle
autocmd FileType go autocmd BufWritePre <buffer> Fmt
autocmd Filetype go set makeprg=go\ build
autocmd! BufWritePost .vimrc source %


" highlight   clear
" highlight   Comment term=standout cterm=bold ctermfg=blue
" highlight   Cursor  cterm=bold ctermbg=2
" highlight   CursorLine   term=none cterm=bold
" highlight   CursorLine   term=none cterm=none ctermbg=8
" highlight   CursorLineNr term=bold ctermfg=8 gui=bold guifg=Yellow
" highlight   LineNr   term=bold ctermfg=8
highlight   Normal ctermbg=black ctermfg=white
" highlight   Folded ctermbg=black ctermfg=darkcyan
" highlight   clear SpellBad
" highlight   OverLength ctermbg=red ctermfg=white guibg=#592929
" match       OverLength /\%81v.\+/
" highlight   Pmenu         ctermfg=0 ctermbg=2
" highlight   PmenuSel      ctermfg=0 ctermbg=7
" highlight   PmenuSbar     ctermfg=7 ctermbg=0
" highlight   PmenuThumb    ctermfg=0 ctermbg=7
highlight   SpellBad term=underline cterm=underline ctermfg=red
" highlight   Search cterm=NONE ctermfg=yellow ctermbg=red
" highlight   TabLine ctermbg=blue
" highlight   TabLineFill ctermbg=green
" highlight   TabLineSel ctermbg=red
" Default Colors for CursorLine
" Change Color when entering Insert Mode
" autocmd InsertEnter * highlight  CursorLine term=bold ctermbg=17 ctermfg=None

" Revert Color to default when leaving Insert Mode
" autocmd InsertLeave * highlight  CursorLine term=none ctermbg=8 cterm=None

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
autocmd BufNewFile,BufRead .vimrc set filetype=vim
autocmd BufRead,BufNewFile *.md set filetype=markdown
autocmd BufNewFile,BufRead *.t set filetype=perl
autocmd BufNewFile,BufRead *.py set filetype=python
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd BufNewFile,BufRead *.js,*.jsx set filetype=javascript
autocmd BufNewFile,BufRead,BufEnter *.go call SetGoOptions()
autocmd BufNewFile,BufRead,BufEnter *.py call SetGoOptions()
autocmd BufNewFile,BufRead,BufEnter *.js,*.jsx call SetGoOptions()

" // Setting different cursorline color in different mode
" augroup CursorLine
"     au!
"     au VimEnter,WinEnter,BufWinEnter * setlocal nocursorline
"     au WinLeave * setlocal nocursorline
" augroup END

" if !exists('g:airline_symbols')
"     let g:airline_symbols = {}
" endif

" let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

let g:syntastic_error_symbol='>>'
let g:syntastic_warning_symbol='>'
let g:syntastic_check_on_open=1
let g:syntastic_enable_highlighting = 0
let g:syntastic_go_checkers=['gofmt']
" let g:syntastic_python_checker="flake8,pyflakes,pep8,pylint""
let g:syntastic_python_checkers=['pyflakes']
let g:syntastic_javascript_checkers = ['jsl', 'jshint']
let g:syntastic_html_checkers=['tidy', 'jshint']
highlight SyntasticErrorSign guifg=white guibg=black

" unicode symbols
" let g:airline_left_sep = '»'
" let g:airline_left_sep = '▶'
" let g:airline_right_sep = '«'
" let g:airline_right_sep = '◀'
" let g:airline_symbols.linenr = '␊'
" let g:airline_symbols.linenr = '␤'
" let g:airline_symbols.linenr = '¶'
" let g:airline_symbols.branch = '⎇'
" let g:airline_symbols.paste = 'ρ'
" let g:airline_symbols.paste = 'Þ'
" let g:airline_symbols.paste = '∥'
" let g:airline_symbols.whitespace = 'Ξ'
