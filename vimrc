scriptencoding utf-8

call pathogen#infect()
syntax on
filetype off
filetype plugin indent on
colorscheme molokai
" colorscheme solarized

"  _____                           _
" |  __ \                         | |
" | |  \/ ___ _ __   ___ _ __ __ _| |
" | | __ / _ \ '_ \ / _ \ '__/ _` | |
" | |_\ \  __/ | | |  __/ | | (_| | |
"  \____/\___|_| |_|\___|_|  \__,_|_|
" For CentOS
" set runtimepath+=/usr/lib/golang/misc/vim " replace $GOROOT with the output of: go env GOROOT
" For uBuntu
set runtimepath+=/usr/local/go/misc/vim " replace $GOROOT with the output of: go env GOROOT  "

" Prevent flash close windows
set completeopt-=preview

set autowrite
set autoread
set backspace=indent,eol,start
set display+=lastline
set encoding=utf-8
set expandtab
set fileformats=unix,dos,mac
set hlsearch
set ignorecase
set incsearch
set laststatus=2
set lazyredraw
set list
set listchars=trail:⋅,nbsp:⋅,tab:▸\ 
set nobackup
set nocompatible
set nocursorline
set nocursorcolumn
set nojoinspaces
set noswapfile
set number
set ruler
set scrolloff=1
set shiftwidth=4
set showcmd
set smartcase
set softtabstop=4
set splitright
set splitbelow
set switchbuf+=usetab,newtab
set textwidth=0
set ttyfast
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
set wildmenu

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" set leader to ,
let g:mapleader                               = ","
let g:tagbar_width                            = 80
let g:bufferline_echo                         = 0
" let g:SuperTabDefaultCompletionType           = "context"
let g:SuperTabDefaultCompletionType           = '<c-n>'

let g:airline_powerline_fonts                 = 1
let g:airline#extensions#tabline#enabled      = 1
let g:airline#extensions#tabline#left_sep     = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'

let g:syntastic_always_populate_loc_list      = 1
let g:syntastic_auto_loc_list                 = 1
let g:syntastic_check_on_open                 = 1
let g:syntastic_check_on_wq                   = 1
let g:syntastic_enable_highlighting           = 1
let g:syntastic_error_symbol                  = '❌'
let g:syntastic_loc_list_height               = 5
let g:syntastic_style_error_symbol            = '⁉️'
let g:syntastic_style_warning_symbol          = '💩'
let g:syntastic_warning_symbol                = '⚠️'

let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/]\.(git|hg|svn)$',
    \ 'file': '\v\.(exe|so|dll)$',
    \ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
    \ }


" Specific filetype by file name
autocmd  BufEnter           *           call   MyLastWindow()
autocmd  BufNewFile,BufRead *.md        set    filetype=markdown
autocmd  BufNewFile,BufRead *.sh        set    filetype=sh
autocmd  BufNewFile,BufRead *.sql       set    filetype=sql
autocmd  BufNewFile,BufRead *.t         set    filetype=perl
autocmd  BufNewFile,BufRead *.yml       set    filetype=yaml
autocmd  BufNewFile,BufRead .vimrc      set    filetype=vim
autocmd  BufNewFile,BufRead Jenkinsfile set    filetype=groovy
autocmd  StdinReadPre       *           let    s:std_in=1
autocmd! BufWritePost       .vimrc      source %

autocmd  VimEnter           *           if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Enable to copy to clipboard for operations like yank, delete, change and put
" http://stackoverflow.com/questions/20186975/vim-mac-how-to-copy-to-clipboard-without-pbcopy
if has('unnamedplus')
  set clipboard^=unnamed
  set clipboard^=unnamedplus
endif

" This enables us to undo files even if you exit Vim.
if has('persistent_undo')
  set undofile
  set undodir=~/.config/vim/tmp/undo//
endif

" // Setting different cursorline color in different mode
" augroup CursorLine
"     au!
"     au VimEnter,WinEnter,BufWinEnter * setlocal nocursorline
"     au WinLeave * setlocal nocursorline
" augroup END

"  _____ _
" |_   _| |
"   | | | |__   ___ _ __ ___   ___  ___ 
"   | | | '_ \ / _ \ '_ ` _ \ / _ \/ __|
"   | | | | | |  __/ | | | | |  __/\__ \
"   \_/ |_| |_|\___|_| |_| |_|\___||___/

" highlight Comment            term=standout             cterm=bold       ctermfg=blue
" highlight CursorLine         cterm=none                ctermbg=240
" highlight CursorLineNr       ctermfg=8                 ctermbg=8
" highlight Folded             ctermbg=black             ctermfg=darkcyan
" highlight OverLength         ctermbg=red               ctermfg=white    guibg=#592929
" highlight Search             cterm=NONE                ctermfg=yellow   ctermbg=red
" highlight SyntasticErrorSign ctermfg=red
" highlight TabLine            ctermbg=blue
" highlight TabLineFill        ctermbg=green
" highlight TabLineSel         ctermbg=red
" highlight clear
" highlight clear              SpellBad
" match     OverLength         /\\%81v.\\+/
highlight Cursor             ctermfg=0                 ctermbg=10
highlight LineNr             ctermfg=DarkGrey          ctermbg=233
highlight Normal             ctermbg=black             ctermfg=white
highlight Pmenu              ctermfg=248               ctermbg=240
highlight PmenuSbar          ctermbg=232
highlight PmenuSel           ctermfg=0                 ctermbg=248
highlight PmenuThumb         ctermfg=240               ctermbg=248
highlight SpellBad           term=underline            cterm=underline  ctermfg=red
highlight Visual             cterm=bold                ctermbg=240
highlight link               SyntasticErrorSign        SignColumn
highlight link               SyntasticStyleErrorSign   SignColumn
highlight link               SyntasticStyleWarningSign SignColumn
highlight link               SyntasticWarningSign      SignColumn

" Default Colors for CursorLine
" Change Color when entering Insert Mode
" autocmd InsertEnter * highlight  CursorLine term=bold ctermbg=17 ctermfg=None

" Revert Color to default when leaving Insert Mode
" autocmd InsertLeave * highlight  CursorLine term=none ctermbg=8 cterm=None

" unicode symbols
" let g:airline_left_sep = '»'
" let g:airline_left_sep = '▶'
" let g:airline_right_sep = '«'
" let g:airline_right_sep = '◀'

"  _   __          ___  ___
" | | / /          |  \/  |
" | |/ /  ___ _   _| .  . | __ _ _ __
" |    \ / _ \ | | | |\/| |/ _` | '_ \
" | |\  \  __/ |_| | |  | | (_| | |_) |
" \_| \_/\___|\__, \_|  |_/\__,_| .__/
"              __/ |            | |
"             |___/             |_|
nmap     <silent> <F1>       :NERDTreeToggle<CR>
" nmap     <silent> <F2>       :set paste!<CR>:set paste?<CR>
nmap     <silent> <F2>       :TagbarToggle<CR>
nmap     <silent> <F3>       :set number!<CR>:set number?<CR>
nmap     <silent> <F4>       :set invlist!<CR>:set invlist?<CR>
nmap     <F5>                :AlignCtrl I= =
nmap     <silent> <F6>       :Align<CR>
nmap     <silent> <F7> <Esc> :TagbarToggle<CR>
nmap     <silent> <F8> <Esc> :setlocal spell spelllang=en_us<CR>
nmap     <silent> <F9> <Esc> :setlocal nospell<CR>
nnoremap tc                  :tabnew<CR>
nnoremap th                  :tabfirst<CR>
nnoremap tj                  :tabnext<CR>
nnoremap tk                  :tabprev<CR>
nnoremap tl                  :tablast<CR>
nnoremap tm                  :tabm<Space>
nnoremap tt                  :tabedit<Space>
nnoremap tx                  :tabclose<CR>

map      <C-n>               :cnext<CR>
map      <c-m>               :cprevious<CR>
nnoremap <leader>a           :cclose<CR>
" Visual linewise up and down by default (and use gj gk to go quicker)
noremap <Up> gk
noremap <Down> gj
noremap j gj
noremap k gk

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
nnoremap n nzzzv
nnoremap N Nzzzv

" Act like D and C
nnoremap Y y$

" deoplete tab-complete
inoremap <expr><tab> pumvisible()? "\<c-n>" : "\<tab>"

" Enter automatically into the files directory
autocmd BufEnter * silent! lcd %:p:h

"   _____       _
"  |  __ \     | |
"  | |__) |   _| |__  _   _
"  |  _  / | | | '_ \| | | |
"  | | \ \ |_| | |_) | |_| |
"  |_|  \_\__,_|_.__/ \__, |
"                      __/ |
"                     |___/
autocmd BufNewFile,BufRead Gemfile,Vagrantfile,*.rb set filetype=ruby

"   _____       _   _
"  |  __ \     | | | |
"  | |__) |   _| |_| |__   ___  _ __
"  |  ___/ | | | __| '_ \ / _ \| '_ \
"  | |   | |_| | |_| | | | (_) | | | |
"  |_|    \__, |\__|_| |_|\___/|_| |_|
"          __/ |
"         |___/
" autocmd FileType python     map <leader>t :call VimuxRunCommand("restart tellus-portal")<CR>
autocmd BufNewFile,BufRead *.py set filetype=python
autocmd FileType python set omnifunc=pythoncomplete#Complete
" autocmd FileType python,shell,coffee set commentstring=#\ %s
" let g:syntastic_python_checker="flake8,pyflakes,pep8,pylint""
let g:syntastic_python_checkers=['pyflakes']


"        _                                _       _
"       | |                              (_)     | |
"       | | __ ___   ____ _ ___  ___ _ __ _ _ __ | |_
"   _   | |/ _` \ \ / / _` / __|/ __| '__| | '_ \| __|
"  | |__| | (_| |\ V / (_| \__ \ (__| |  | | |_) | |_
"   \____/ \__,_| \_/ \__,_|___/\___|_|  |_| .__/ \__|
"                                          | |
"                                          |_|
autocmd BufNewFile,BufRead *.json,*.js,*.jsx set filetype=javascript
let g:syntastic_javascript_checkers = ['jsl', 'jshint']
let g:syntastic_html_checkers=['tidy', 'jshint']

"  _____  _
" |  __ \| |
" | |__) | |__  _ __
" |  ___/| '_ \| '_ \
" | |    | | | | |_) |
" |_|    |_| |_| .__/
"              | |
"              |_|
let g:tagbar_phpctags_bin='~/.vim/opt/phpctags'
let g:tagbar_phpctags_memory_limit = '512M'

"  _____                    __
" |_   _|                  / _|
"   | | ___ _ __ _ __ __ _| |_ ___  _ __ _ __ ___  
"   | |/ _ \ '__| '__/ _` |  _/ _ \| '__| '_ ` _ \ 
"   | |  __/ |  | | | (_| | || (_) | |  | | | | | |
"   \_/\___|_|  |_|  \__,_|_| \___/|_|  |_| |_| |_|
" let g:terraform_align=1
autocmd FileType terraform setlocal commentstring=#%s
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif
" (Optional) Enable terraform plan to be include in filter
let g:syntastic_terraform_tffilter_plan = 1

" (Optional) Default: 0, enable(1)/disable(0) plugin's keymapping
let g:terraform_completion_keys = 1

" (Optional) Default: 1, enable(1)/disable(0) terraform module registry completion
let g:terraform_registry_module_completion = 1

let g:deoplete#omni_patterns = {}
let g:deoplete#omni_patterns.terraform = '[^ *\t"{=$]\w*'
let g:deoplete#enable_at_startup = 1
call deoplete#initialize()

"    _____       _
"   / ____|     | |
"  | |  __  ___ | | __ _ _ __   __ _
"  | | |_ |/ _ \| |/ _` | '_ \ / _` |
"  | |__| | (_) | | (_| | | | | (_| |
"   \_____|\___/|_|\__,_|_| |_|\__, |
"                               __/ |
"                              |___/
let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
let g:deoplete#sources#go#package_dot   = 1
let g:deoplete#sources#go#sort_class    = ['package', 'func', 'type', 'var', 'const']
let g:deoplete#sources#go#pointer       = 1

let g:syntastic_go_checkers          = ['go']
let g:syntastic_mode_map             = { 'mode': 'active', 'active_filetypes':['go'], 'passive_filetypes': [] }

let g:go_auto_sameids                = 0
let g:go_auto_type_info              = 1
let g:go_decls_includes              = "func,type"
let g:go_def_use_buffer              = 1
let g:go_def_mapping_enabled         = 0
" let g:go_def_mode                    = "godef"
let g:go_fmt_autosave                = 1
let g:go_fmt_command                 = "goimports"
let g:go_fmt_fail_silently           = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_extra_types       = 1
let g:go_highlight_fields            = 1
let g:go_highlight_functions         = 1
let g:go_highlight_interfaces        = 1
let g:go_highlight_methods           = 1
let g:go_highlight_operators         = 1
let g:go_highlight_structs           = 1
let g:go_highlight_types             = 1
let g:go_list_type                   = "quickfix"
let g:go_metalinter_autosave         = 0
let g:go_metalinter_deadline         = "5s"
let g:go_metalinter_enabled          = ['vet', 'golint', 'errcheck']
let g:go_play_open_browser           = 0
let g:go_test_timeout                = '10s'
set updatetime =100
autocmd Filetype go                  command! -bang A call go#alternate#Switch(<bang>0, 'edit')
autocmd Filetype go                  command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
autocmd Filetype go                  command! -bang AS call go#alternate#Switch(<bang>0, 'split')
autocmd Filetype go                  command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')
autocmd FileType go                  nnoremap <buffer> gt :call go#def#Jump("tab")<CR>
autocmd FileType go                  nmap     <leader>b :<C-u>call <SID>build_go_files()<CR>
autocmd FileType go                  nmap     <leader>c <Plug>(go-coverage-toggle)
autocmd FileType go                  nmap     <leader>C <Plug>(go-coverage-browser)
autocmd FileType go                  nmap     <Leader>d <Plug>(go-doc)
autocmd FileType go                  nmap     <leader>i <Plug>(go-info)
autocmd FileType go                  nmap     <Leader>l <Plug>(go-metalinter)
autocmd FileType go                  nmap     <leader>r <Plug>(go-run)
autocmd FileType go                  nmap     <Leader>s <Plug>(go-def-split)
autocmd FileType go                  nmap     <Leader>v <Plug>(go-def-vertical)
autocmd FileType go                  nmap     <leader>t <Plug>(go-test)
autocmd FileType go                  nmap     <leader>T <Plug>(go-test-func)
autocmd FileType go                  map      <Leader>ra :wa<CR> :GolangTestCurrentPackage<CR>
autocmd FileType go                  map      <Leader>rf :wa<CR> :GolangTestFocused<CR>
" autocmd FileType go         call     SetGoOptions()

let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports',
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
" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

" ______
" |  ___
" | |_ _   _ _ __   ___
" |  _| | | | '_ \ / __|
" | | | |_| | | | | (__
" \_|  \__,_|_| |_|\___|
" Transparent editing of gpg encrypted files.
augroup encrypted
  au!

  " First make sure nothing is written to ~/.viminfo while editing
  " an encrypted file.
  autocmd BufReadPre,FileReadPre *.gpg set viminfo=
  " We don't want a various options which write unencrypted data to disk
  autocmd BufReadPre,FileReadPre *.gpg set noswapfile noundofile nobackup

  " Switch to binary mode to read the encrypted file
  autocmd BufReadPre,FileReadPre *.gpg set bin
  autocmd BufReadPre,FileReadPre *.gpg let ch_save = &ch|set ch=2
  " (If you use tcsh, you may need to alter this line.)
  autocmd BufReadPost,FileReadPost *.gpg '[,']!gpg --decrypt 2> /dev/null

  " Switch to normal mode for editing
  autocmd BufReadPost,FileReadPost *.gpg set nobin
  autocmd BufReadPost,FileReadPost *.gpg let &ch = ch_save|unlet ch_save
  autocmd BufReadPost,FileReadPost *.gpg execute ":doautocmd BufReadPost " . expand("%:r")

  " Convert all text to encrypted text before writing
  " (If you use tcsh, you may need to alter this line.)
  autocmd BufWritePre,FileWritePre *.gpg '[,']!gpg --default-recipient-self -ae 2>/dev/null
  " Undo the encryption so we are back in the normal text, directly
  " after the file has been written.
  autocmd BufWritePost,FileWritePost *.gpg u
augroup END
    if &term =~ "xterm.*"
        let &t_ti = &t_ti . "\e[?2004h"
        let &t_te = "\e[?2004l" . &t_te
        function! XTermPasteBegin(ret)
            set pastetoggle=<Esc>[201~
            set paste
            return a:ret
        endfunction
        map <expr> <Esc>[200~ XTermPasteBegin("i")
        imap <expr> <Esc>[200~ XTermPasteBegin("")
        cmap <Esc>[200~ <nop>
        cmap <Esc>[201~ <nop>
    endif

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
     :call tagbar#autoopen(0)
endfunction

" The Silver Searcher for CtrlP
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
  " bind \ (backward slash) to grep shortcut
  command! -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
else
    let g:ctrlp_user_command = 'find %s -not -path "*/\.*" -type f -exec grep -Iq . {} \; -and -print'
endif

"If this is Terminal.app, do cursor hack for visible cursor
"This hack does not behave well with other terminals (particularly xterm)
function! MacOSX()
  hi CursorLine term=none cterm=none "Invisible CursorLine
  set cursorline "cursorline required to continuously update cursor position
  hi Cursor cterm=bold "I like a reversed cursor, edit this to your liking
  match Cursor /\%#/ "This line does all the work
endfunction

if $TERM_PROGRAM == "Apple_Terminal" " Terminal.app, xterm and urxvt pass this test
 if $WINDOWID == ""                  " xterm and urxvt don't pass this test
  "It is unlikely that anything except Terminal.app will get here
  call MacOSX()
 endif
endif

if $SSH_TTY != ""            " If the user is connected through ssh
 if $TERM == "xterm-color" || $ORIGTERM = "xterm-color"
  "Something other than Terminal.app might well get here
  call MacOSX()
 endif
endif
