" This settings must be first, because it changes other options as a side effect
set nocompatible       " use Vim settings, rather then Vi settings
syntax on              " turn on syntax highlighting (this will turn 'filetype on' by default)
filetype plugin indent on  " turn on file type detection


" Base settings -----------------------------------------------------------------------------------
set hidden             " the current buffer can be put to the background without writing to disk
set number             " show line numbers
set cursorline         " highlight the screen line of the cursor
set nowrap             " do not wrap long lines
set nofoldenable       " turn off folding
set scrolloff=3        " minimal number of screen lines to keep above and below the cursor
set showcmd            " show the size of the visually-selected area
set wildmenu           " turn on wildmenu (enhanced mode of command-line completion)
set wcm=<Tab>          " wildmenu navigation key
set laststatus=2       " always show the status line
set tabstop=4          " number of spaces that a <Tab> in the file counts for
set softtabstop=4      " number of spaces that a <Tab> counts for while performing
                       " editing operations, like inserting a <Tab> or using <BS>
set shiftwidth=4       " number of spaces to use for each step of (auto)indent
set smarttab           " use different amount of spaces in a front of line or in other places
                       " according to 'tabstop', 'softtabstop' and 'shiftwidth' settings
set autoindent         " copy indent from current line when starting a new line
set incsearch          " jump to search results while typing a search command
set hlsearch           " always highlight all matches of previous search pattern
set gdefault           " turn on the ':substitute' flag 'g' by default
set backspace=indent,eol,start  " allow backspacing over everything in insert mode
set encoding=utf-8     " sets the character encoding used inside Vim
set fileencodings=utf8,cp1251  " list of character encodings considered
                               " when starting to edit an existing file
set fillchars=vert:\ ,fold:-  " characters for fill statuslines and vertical separators
set listchars=tab:⇥\ ,trail:·,extends:⋯,precedes:⋯,eol:¬  " invisible symbols representation
set list               " display unprintable characters by default
set wildignore+=.git,*.o,*.pyc,.DS_Store  " list of ignored in expanding wildcards files
set nobackup           " do not create backup files
set noswapfile         " do not create swap files

" rolodex Vim
set noequalalways      " makes sure Vim doesn't try to make all windows equal
set winminheight=0     " non-current windows may collapse to a status line and nothing else
set winheight=9999     " current window to maximum height
set helpheight=9999    " current help window to maximum height


" Setup colorscheme -------------------------------------------------------------------------------
set background=light   " Vim will try to use colors that look good on a light background
try
    colorscheme solarized  " try to setup colorscheme
    " reload 'mark' plugin after colorscheme changed
    " if filereadable($HOME."/.vim/plugin/mark.vim")
    "     source ~/.vim/plugin/mark.vim
    " endif
catch /^Vim\%((\a\+)\)\=:E185/
    " cannot find color scheme
endtry


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
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%

" emacs style jump to end of line
imap <C-e> <C-o>A
imap <C-a> <C-o>I

" Ctrl+Tab switch buffers, Ctrl+Shift+Tab switch buffers back
map <C-tab> :bnext<CR>
map <C-S-tab> :bprevious<CR>


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
