" This settings must be first, because it changes other options as a side effect
set nocompatible           " use Vim settings, rather then Vi settings

" Setup plugins
set runtimepath+=/Users/rudnyh/.vim/bundles/repos/github.com/Shougo/dein.vim
if dein#load_state('/Users/rudnyh/.vim/bundles')
  call dein#begin('/Users/rudnyh/.vim/bundles')
  call dein#add('/Users/rudnyh/.vim/bundles/repos/github.com/Shougo/dein.vim')

  " plugins list start
  call dein#add('altercation/vim-colors-solarized')
  call dein#add('tpope/vim-unimpaired')
  call dein#add('mileszs/ack.vim')
  call dein#add('ctrlpvim/ctrlp.vim')
  call dein#add('taq/vim-git-branch-info')
  call dein#add('andviro/flake8-vim')
  call dein#add('airblade/vim-gitgutter')
  call dein#add('tpope/vim-fugitive')
  " end of plugins list

  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
  call dein#install()      " check and install plugins on startup
endif

syntax on                  " turn on syntax highlighting (this will turn 'filetype on' by default)
filetype plugin indent on  " turn on file type detection


" Base settings -----------------------------------------------------------------------------------
set hidden                 " the current buffer can be put to the background without writing it on disk
set number                 " show line numbers
set cursorline             " highlight the screen line of the cursor
set nowrap                 " do not wrap long lines
set nofoldenable           " turn off folding
set scrolloff=3            " minimal number of screen lines to keep above and below the cursor
set showcmd                " show the size of the visually-selected area
set wildmenu               " turn on wildmenu (enhanced mode of command-line completion)
set wcm=<Tab>              " wildmenu navigation key
set laststatus=2           " always show the status line
set tabstop=4              " number of spaces that a <Tab> in the file counts for
set softtabstop=4          " number of spaces that a <Tab> counts for while performing
                           " editing operations, like inserting a <Tab> or using <BS>
set shiftwidth=4           " number of spaces to use for each step of (auto)indent
set smarttab               " use different amount of spaces in a front of line or in other places
                           " according to 'tabstop', 'softtabstop' and 'shiftwidth' settings
set autoindent             " copy indent from current line when starting a new line
set incsearch              " jump to search results while typing a search command
set hlsearch               " always highlight all matches of previous search pattern
set gdefault               " turn on the ':substitute' flag 'g' by default
set backspace=indent,eol,start  " allow backspacing over everything in insert mode
set encoding=utf-8              " sets the character encoding used inside Vim
set fileencodings=utf8,cp1251   " list of character encodings considered
                                " when starting to edit an existing file
set fillchars=vert:\ ,fold:-    " characters for fill statuslines and vertical separators
set listchars=tab:⇥\ ,trail:·,extends:⋯,precedes:⋯,eol:¬  " invisible symbols representation
set nolist                 " do not display unprintable characters by default
set wildignore+=.git,*.o,*.pyc,.DS_Store  " list of ignored in expanding wildcards files
set nobackup               " do not create backup files
set noswapfile             " do not create swap files

" rolodex Vim
set noequalalways          " makes sure Vim doesn't try to make all windows equal
set winminheight=0         " non-current windows may collapse to a status line and nothing else
set winheight=9999         " current window to maximum height
set helpheight=9999        " current help window to maximum height


" Setup colorscheme -------------------------------------------------------------------------------
set background=light       " Vim will try to use colors that look good on a light background
try
    colorscheme solarized  " try to setup colorscheme
    " reload 'mark' plugin after colorscheme changed
    " if filereadable($HOME."/.vim/plugin/mark.vim")
    "     source ~/.vim/plugin/mark.vim
    " endif
catch /^Vim\%((\a\+)\)\=:E185/
    " cannot find color scheme
endtry

" do not highlight current line in inactive windows
augroup BgHighlight
    autocmd!
    autocmd WinEnter * set cul
    autocmd WinLeave * set nocul
augroup END



" Statusline setup --------------------------------------------------------------------------------
" active statusline
function! SwitchToBuffer()
    if &buftype != 'quickfix' && &buftype != 'nofile'
        if exists("*GitBranchInfoTokens")
            let &l:statusline = "%<%f\ %m%r\%=\ git:\ %{GitBranchInfoTokens()[0]}\ \|\ %Y\ \|\ %{&fenc==\"\"?&enc:&fenc}\ \|\ %{&ff}\ \|\ %l,%v\ %P"
        else
            let &l:statusline = "%<%f\ %m%r\%=\ %Y\ \|\ %{&fenc==\"\"?&enc:&fenc}\ \|\ %{&ff}\ \|\ %l,%v\ %P"
        endif
        wincmd _
    endif
endfunction
autocmd BufEnter * call SwitchToBuffer()
autocmd WinEnter * call SwitchToBuffer()

" inactive statusline
autocmd WinLeave * let &l:statusline = '%<%f'


" Ack plugin setup --------------------------------------------------------------------------------
let g:ackhighlight = 1   " highlight the searched term
" let g:ackpreview=1       " auto-preview files when they are selected in the quickfix window
" let g:ack_autoclose = 1  " close the quickfix window after using any of the shortcuts


" CtrlP plugin settings ---------------------------------------------------------------------------
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_max_files = 0  " set no max file limit

if executable('rg')
  set grepprg=rg\ --color=never

  let g:ackprg = 'rg --vimgrep --no-heading'

  let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'  " use ripgrep in CtrlP for listing files
  let g:ctrlp_use_caching = 0                            " ag is fast enough that CtrlP doesn't need to cache
endif


" Flake8 plugin setup -----------------------------------------------------------------------------
let g:PyFlakeOnWrite = 1
let g:PyFlakeCheckers = 'pep8,frosted'


" Lines 'bubbling' --------------------------------------------------------------------------------
" see also: http://vimcasts.org/episodes/bubbling-text/
" single lines
nmap <C-Up> [e
nmap <C-Down> ]e
" multiple lines
vmap <C-Up> [egv
vmap <C-Down> ]egv


" Keys remapping ----------------------------------------------------------------------------------
nnoremap ; :
let mapleader=','

" print setting state
function! EchoSetting(name)
    exec 'let l:state = &'.a:name
    echon l:state ? a:name.' = ON' : a:name.' = OFF'
endfunction

" toggle 'set list' (http://vimcasts.org/episodes/show-invisibles/)
nmap <silent> <leader>l :set list!<CR>:call EchoSetting('list')<CR>

" toggle 'set wrap'
nmap <silent> <leader>w :set wrap!<CR>:call EchoSetting('wrap')<CR>

" toggle 'set ignorecase'
nmap <silent> <leader>i :set ignorecase!<CR>:call EchoSetting('ignorecase')<CR>

" toggle 'set number'
nmap <silent> <leader>u :set number!<CR>:call EchoSetting('number')<CR>

" toggle 'set hls'
nmap <silent> <leader>H :set hlsearch!<CR>:call EchoSetting('hlsearch')<CR>
nmap <silent> <leader>h :nohlsearch<CR>

" current file directory expand (http://vimcasts.org/episodes/the-edit-command/)
cnoremap %% <C-R>=expand('%:h').'/'<CR>

" emacs style jump to end of line
nmap <C-a> ^
nmap <C-e> $
imap <C-a> <C-o>I
imap <C-e> <C-o>A

" Ctrl+Tab switch buffers, Ctrl+Shift+Tab switch buffers back
map <C-tab> :bnext<CR>
map <C-S-tab> :bprevious<CR>

" Ctrl+b search buffers
map <C-b> :CtrlPBuffer<CR>


" Autocomplete settings ---------------------------------------------------------------------------
set tags=./tags;/  " tags file

" autocomplete with <Tab> key
function InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
imap <tab> <c-r>=InsertTabWrapper()<CR>
