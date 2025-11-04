" Ascii art generated with http://patorjk.com/software/taag/#p=display&f=ANSI%20Shadow&t=Vim%20Config
scriptencoding utf-8

" May need for Vim (not Neovim) since coc.nvim calculates byte offset by count
" utf-8 byte sequence
set encoding=utf-8

"  ██████  ███████ ███    ██ ███████ ██████   █████  ██
" ██       ██      ████   ██ ██      ██   ██ ██   ██ ██
" ██   ███ █████   ██ ██  ██ █████   ██████  ███████ ██
" ██    ██ ██      ██  ██ ██ ██      ██   ██ ██   ██ ██
"  ██████  ███████ ██   ████ ███████ ██   ██ ██   ██ ███████
syntax on
filetype off
filetype plugin indent on
colorscheme molokai

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
" delays and poor user experience
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved
set signcolumn=yes

" Prevent flash close windows
" (Optional)Remove Info(Preview) window
" set completeopt-=preview

set autoread
set autowrite
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
set nocursorcolumn
set nocursorline
set nojoinspaces
set noswapfile
set number
set ruler
set scrolloff=1
set shiftwidth=4
set showcmd
set smartcase
set softtabstop=4
set splitbelow
set splitright
set switchbuf+=usetab,newtab
set tabstop=4
set textwidth=0
set ttyfast
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
set wildmenu

" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%{fugitive#statusline()}
" set statusline+=%*

" set leader to ,
let g:mapleader                               = ","
let g:bufferline_echo                         = 0

let g:airline_powerline_fonts                 = 1
let g:airline#extensions#tabline#enabled      = 1
let g:airline#extensions#tabline#left_sep     = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#formatter    = 'unique_tail'

" nmap     <silent> <F1>       :CocCommand explorer<CR>
" nmap     <silent> <F2>       :Vista!!<CR>
nmap     <silent> <F3>       :set number!<CR>:set number?<CR>
nmap     <silent> <F4>       :set invlist!<CR>:set invlist?<CR>
nnoremap bf                  :bfirst<CR>
nnoremap bn                  :bnext<CR>
nnoremap bp                  :bprev<CR>
nnoremap bl                  :blast<CR>

map      <C-j>               :lnext<CR>
map      <c-k>               :lprevious<CR>
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

" Remove trailing whitespace by pressing F5
nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

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

autocmd  BufEnter           *           call   MyLastWindow()
function! MyLastWindow()
" if the window is quickfix go on
  if &buftype=="quickfix"
" if this window is last on screen quit without warning
    if winbufnr(2) == -1
      quit!
    endif
  endif
  if (winnr("$") == 1 && vista#sidebar#IsOpen()) | q | endif
endfunction

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

autocmd BufNewFile,BufRead *.dac setlocal filetype=yaml
autocmd BufWritePost *.dac silent !awsdac % -o %.png >/dev/null 2>&1

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

" ██   ██ ██    ██      ██ ███████  ██████  ███    ██ 
" ██   ██ ██    ██      ██ ██      ██    ██ ████   ██ 
" ███████ ██    ██      ██ ███████ ██    ██ ██ ██  ██ 
" ██   ██ ██    ██ ██   ██      ██ ██    ██ ██  ██ ██ 
" ██   ██  ██████   █████  ███████  ██████  ██   ████
autocmd FileType hjson set noexpandtab
autocmd BufNewFile,BufRead *.hujson setlocal filetype=hjson
autocmd FileType hjson setlocal foldmethod=syntax
nnoremap <space> za

" ███████  █████  ███████ ██    ██  █████  ██      ██  ██████  ███    ██
" ██      ██   ██ ██       ██  ██  ██   ██ ██      ██ ██       ████   ██
" █████   ███████ ███████   ████   ███████ ██      ██ ██   ███ ██ ██  ██
" ██      ██   ██      ██    ██    ██   ██ ██      ██ ██    ██ ██  ██ ██
" ███████ ██   ██ ███████    ██    ██   ██ ███████ ██  ██████  ██   ████
" format/start/easyAlign
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)


"  ██████  ██ ████████  ██████  ██    ██ ████████ ████████ ███████ ██████
" ██       ██    ██    ██       ██    ██    ██       ██    ██      ██   ██
" ██   ███ ██    ██    ██   ███ ██    ██    ██       ██    █████   ██████
" ██    ██ ██    ██    ██    ██ ██    ██    ██       ██    ██      ██   ██
"  ██████  ██    ██     ██████   ██████     ██       ██    ███████ ██   ██
"  pack/git/start/vim-gitgutter
"  ]c   Jump to next hunk
"  [c   Jump to previous hunk
"  <leader>hp   Preview the hunk under the cursor
"  <leader>hr   Reset the hunk under the cursor
"  <leader>hs   Stage the hunk under the cursor
"  <leader>hu   Undo the hunk under the cursor
"

" ███████ ██████  ██      ██ ████████      ██  ██████  ██ ███    ██
" ██      ██   ██ ██      ██    ██         ██ ██    ██ ██ ████   ██
" ███████ ██████  ██      ██    ██         ██ ██    ██ ██ ██ ██  ██
"      ██ ██      ██      ██    ██    ██   ██ ██    ██ ██ ██  ██ ██
" ███████ ██      ███████ ██    ██     █████   ██████  ██ ██   ████
" pack/format/start/splitjoin.vim
" gS   Split one-liners into multiple lines.
" gJ   Join multiple lines into one.
" gss  Split one-liners without space.
" gsj  Split one-liners with space.
" gSj  Split one-liners with space and join them back.
" gSs  Split one-liners without space and join them back.
" gJj  Join lines with space.
" gJJ  Join lines without space.
" gJc  Join lines with space and add a leading comment sign.
" gCc  Join lines without space and add a leading comment sign.
" gJm  Join lines with space and add a trailing comment sign.
" gCm  Join lines without space and add a trailing comment sign.
" gJp  Join lines with space and add a trailing comma.
" gCp  Join lines without space and add a trailing comma.
" gJd  Join lines with space and add a trailing dot.
" gCd  Join lines without space and add a trailing dot.


" ███████ ██    ██ ██████  ██████   ██████  ██    ██ ███    ██ ██████
" ██      ██    ██ ██   ██ ██   ██ ██    ██ ██    ██ ████   ██ ██   ██
" ███████ ██    ██ ██████  ██████  ██    ██ ██    ██ ██ ██  ██ ██   ██
"      ██ ██    ██ ██   ██ ██   ██ ██    ██ ██    ██ ██  ██ ██ ██   ██
" ███████  ██████  ██   ██ ██   ██  ██████   ██████  ██   ████ ██████
" pack/format/start/vim-surround
" cs"'     change surround " to ',    'Hello world!'
" cs'<q>   change surround ' to <q>,  <q>Hello world!</q>
" ds       delete surround ",         Hello world!
" ysiw]    surround word with [],     [Hello] world!
" cs]}     surround word with {},     {Hello} world!
" yssb     surround line with (),     ({Hello} world!)
" ds{ds)   delete surround {} and (), Hello world!
" ysiw<em> surround word with <em></em>, <em>Hello</em> world!
" Press a capital V (for linewise visual mode) followed by S<p class="important">.
" <p class="important">
"   <em>Hello</em> world!
" </p>

" ██████  ██████   ██████               ███████ ███    ██ ██ ██████  ██████  ███████ ████████ ███████
"██      ██    ██ ██                    ██      ████   ██ ██ ██   ██ ██   ██ ██         ██    ██
"██      ██    ██ ██          █████     ███████ ██ ██  ██ ██ ██████  ██████  █████      ██    ███████
"██      ██    ██ ██                         ██ ██  ██ ██ ██ ██      ██      ██         ██         ██
" ██████  ██████   ██████               ███████ ██   ████ ██ ██      ██      ███████    ██    ███████
" https://github.com/neoclide/coc-snippets

" Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)

" Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)

" Use <C-j> for jump to next placeholder, it's default of coc.nvim
let g:coc_snippet_next = '<c-j>'

" Use <C-k> for jump to previous placeholder, it's default of coc.nvim
let g:coc_snippet_prev = '<c-k>'

" Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-j> <Plug>(coc-snippets-expand-jump)

" Use <leader>x for convert visual selected code to snippet
xmap <leader>x  <Plug>(coc-convert-snippet)

inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

"  ██████  ██████  ██████  ██ ██       ██████  ████████
" ██      ██    ██ ██   ██ ██ ██      ██    ██    ██
" ██      ██    ██ ██████  ██ ██      ██    ██    ██
" ██      ██    ██ ██      ██ ██      ██    ██    ██
"  ██████  ██████  ██      ██ ███████  ██████     ██
"  pack/theme/start/copilot.vim
let g:copilot_filetypes = {
    \ 'gitcommit': v:true,
    \ 'markdown': v:true,
    \ 'yaml': v:true
    \ }
autocmd BufReadPre *
    \ let f=getfsize(expand("<afile>"))
    \ | if f > 100000 || f == -2
    \ | let b:copilot_enabled = v:false
    \ | endif
" let g:copilot_no_tab_map = v:true
imap <silent> <C-j> <Plug>(copilot-next)
imap <silent> <C-k> <Plug>(copilot-previous)
imap <silent> <C-\> <Plug>(copilot-dismiss)


" ██    ██ ██ ███████ ████████  █████
" ██    ██ ██ ██         ██    ██   ██
" ██    ██ ██ ███████    ██    ███████
"  ██  ██  ██      ██    ██    ██   ██
"   ████   ██ ███████    ██    ██   ██
" theme/start/vista
function! NearestMethodOrFunction() abort
  return get(b:, 'vista_nearest_method_or_function', '')
endfunction

set statusline+=%{NearestMethodOrFunction()}
" By default vista.vim never run if you don't call it explicitly.
"
" If you want to show the nearest function in your statusline automatically,
" you can add the following line to your vimrc
function! NearestMethodOrFunction() abort
  return get(b:, 'vista_nearest_method_or_function', '')
endfunction
autocmd VimEnter * call vista#RunForNearestMethodOrFunction()

" How each level is indented and what to prepend.
" This could make the display more compact or more spacious.
" e.g., more compact: ["▸ ", ""]
" Note: this option only works for the kind renderer, not the tree renderer.
let g:vista_icon_indent = ["╰─▸ ", "├─▸ "]

" Executive used when opening vista sidebar without specifying it.
" See all the avaliable executives via `:echo g:vista#executives`.
let g:vista_default_executive = 'coc'
" Ensure you have installed some decent font to show these pretty symbols, then you can enable icon for the kind.
let g:vista#renderer#enable_icon = 1

let g:vista#finders = ['fzf']
let g:vista_fzf_preview = ['right:50%']
let g:vista#renderer#icons = {
\    'augroup': 'פּ',
\    'class': '',
\    'const': '󱓻',
\    'constant': '󱓻',
\    'constructor': '󰮮',
\    'default': '',
\    'enum': '',
\    'enumerator': '',
\    'enummember': '',
\    'field': '',
\    'fields': '',
\    'func': '󰊕',
\    'function': '󰊕',
\    'functions': '󰡱',
\    'implementation': '󱗼',
\    'interface': '',
\    'macro': '󱡃',
\    'macros': '󱡃',
\    'map': '󰿘',
\    'member': '',
\    'method': '',
\    'module': '',
\    'modules': '',
\    'namespace': '',
\    'package': '',
\    'packages': '',
\    'property': '',
\    'struct': '',
\    'subroutine': '羚',
\    'target': '',
\    'type': '',
\    'typeParameter': '',
\    'typedef': '',
\    'types': '',
\    'union': '󰕤',
\    'var': '󰫧',
\    'variable': '󰫧',
\    'variables': '󰫧'
\    }

let g:vista_echo_cursor_strategy = 'floating_win'
let g:vista_floating_border = 'rounded'
let g:vista_sidebar_width = '50'
autocmd FileType vista,vista_kind nnoremap <buffer> <silent> / :<c-u>call vista#finder#fzf#Run()<CR>
let g:vista_keep_fzf_colors = 1

" let g:vista_no_mappings            = 1
let g:vista_sidebar_width          = 50
let g:vista_update_on_text_changed = 1
let g:vista_blink                  = [1, 100]

nmap <silent> <Leader>v <Cmd>Vista!!<CR>
nmap <silent> <Leader>vf <Cmd>Vista focus<CR>

function! s:vista_settings() abort
   nmap <silent> <buffer> <nowait> q    <Cmd>quit<CR>
   nmap <silent> <buffer>          <CR> <Cmd>call vista#cursor#FoldOrJump()<CR>
   nmap <silent> <buffer>          p    <Cmd>call vista#cursor#TogglePreview()<CR>
endfunction

autocmd FileType vista,vista_markdown call <SID>vista_settings()
nmap <leader>e :CocCommand explorer<CR>
call coc#config('explorer', {
    \ 'icon.enableNerdfont': 1,
    \})

" ██████  ██    ██ ██████  ██  ██████  ██   ██ ████████
" ██   ██  ██  ██  ██   ██ ██ ██       ██   ██    ██
" ██████    ████   ██████  ██ ██   ███ ███████    ██
" ██         ██    ██   ██ ██ ██    ██ ██   ██    ██
" ██         ██    ██   ██ ██  ██████  ██   ██    ██
" Pyright
" lang/start/pyright
autocmd FileType python map <F5> :w<CR>:!python %<CR>
autocmd FileType python map <F6> :w<CR>:!pytest %<CR>


"  ██████  ██████   ██████
" ██      ██    ██ ██
" ██      ██    ██ ██
" ██      ██    ██ ██
"  ██████  ██████   ██████
" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s)
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying code actions to the selected code block
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying code actions at the cursor position
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Remap keys for apply code actions affect whole buffer
nmap <leader>as  <Plug>(coc-codeaction-source)
" Apply the most preferred quickfix action to fix diagnostic on the current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Remap keys for applying refactor code actions
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

" Run the Code Lens action on the current line
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> to scroll float windows/popups
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges
" Requires 'textDocument/selectionRange' support of language server
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" hi CocInlayHint guibg=Red guifg=Blue ctermbg=Red ctermfg=Blue
hi CocInlayHint guibg=Red guifg=Blue ctermbg=0 ctermfg=71

