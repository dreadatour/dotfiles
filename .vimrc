" Base settings -----------------------------------------------------------------------------------
set nocompatible           " use Vim settings, rather then Vi settings
syntax on                  " turn on syntax highlighting (this will turn 'filetype on' by default)
filetype plugin indent on  " turn on file type detection
set hidden                 " the current buffer can be put to the background without writing it on disk
set nobackup               " do not create backup files
set noswapfile             " do not create swap files
set autowrite              " write the contents of the file on next, previous, make, etc commands
set exrc                   " allows loading local executing rc files
set secure                 " disallows the use of :autocmd, shell and write commands in local rc files

" text and indentaion
set nowrap                 " do not wrap long lines
set textwidth=0            " disable break long lines while editing
set fo-=t                  " disable automatic text wrapping
set autoindent             " copy indent from current line when starting a new line
set tabstop=4              " number of spaces that a <Tab> in the file counts for
set shiftwidth=4           " number of spaces to use for each step of (auto)indent
set softtabstop=4          " number of spaces that a <Tab> counts for while performing
set smarttab               " use different amount of spaces in a front of line or in other places
                           " according to 'tabstop', 'softtabstop' and 'shiftwidth' settings
set backspace=indent,eol,start  " allow backspacing over everything in insert mode
set encoding=utf-8              " sets the character encoding used inside Vim
set fileencodings=utf8     " list of character encodings considered
                           " when starting to edit an existing file

" UI
set showcmd                " show (partial) command in the last line of the screen
set wildmenu               " turn on wildmenu (enhanced mode of command-line completion)
set wcm=<Tab>              " wildmenu navigation key
set laststatus=2           " always show the status line
set incsearch              " jump to search results while typing a search command
set lazyredraw             " redraw only when we need to
set nonumber               " do not show line numbers
set nocursorline           " do not highlight the screen line of the cursor
set nofoldenable           " turn off folding
set scrolloff=3            " minimal number of screen lines to keep above and below the cursor
set splitright             " how to split new windows
set winminheight=0         " non-current windows may collapse to a status line and nothing else
set equalalways            " makes sure Vim try to make all windows equal
set fillchars=vert:\ ,fold:·  " characters for fill statuslines and vertical separators
set background=light       " Vim will try to use colors that look good on a light background

" invisible characters
set nolist                 " do not display unprintable characters by default
set listchars=tab:⇥\ ,trail:·,extends:⋯,precedes:⋯,eol:¬  " invisible symbols representation

" list of ignored in expanding wildcards files
set wildignore+=.git,*.o,*.pyc,__pycache__,.DS_Store

"if &term =~ '256color'
"	" disable Background Color Erase (BCE) so that color schemes
"	" render properly when inside 256-color tmux and GNU screen.
"	" see also http://snk.tuxfamily.org/log/vim-256color-bce.html
"	set t_ut=
"endif
