" This settings must be first, because it changes other options as a side effect
set nocompatible           " use Vim settings, rather then Vi settings

" Setup plugins
set runtimepath+=/Users/rudnyh/.vim/bundles/repos/github.com/Shougo/dein.vim
if dein#load_state('/Users/rudnyh/.vim/bundles')
	call dein#begin('/Users/rudnyh/.vim/bundles')
	call dein#add('/Users/rudnyh/.vim/bundles/repos/github.com/Shougo/dein.vim')

	" plugins list start
	call dein#add('altercation/vim-colors-solarized')
	call dein#add('blueyed/vim-diminactive')
	call dein#add('tpope/vim-unimpaired')
	call dein#add('itchyny/vim-parenmatch')
	call dein#add('alvan/vim-closetag')
	call dein#add('cohama/lexima.vim')
	call dein#add('dreadatour/vim-cursorword')
	call dein#add('mileszs/ack.vim')
	call dein#add('ctrlpvim/ctrlp.vim')
	call dein#add('andviro/flake8-vim')
	call dein#add('Vimjas/vim-python-pep8-indent')
	call dein#add('szw/vim-tags')
	call dein#add('ervandew/supertab')
	" end of plugins list

	call dein#end()
	call dein#save_state()
endif

if dein#check_install()
	call dein#install()    " check and install plugins on startup
endif

syntax on                  " turn on syntax highlighting (this will turn 'filetype on' by default)
filetype plugin indent on  " turn on file type detection


" Base settings -----------------------------------------------------------------------------------
set hidden                 " the current buffer can be put to the background without writing it on disk
set ttyfast                " send more characters at a given time
set lazyredraw             " redraw only when we need to
set nonumber               " do not show line numbers
set nocursorline           " do not highlight the screen line of the cursor
set nowrap                 " do not wrap long lines
set nofoldenable           " turn off folding
set scrolloff=3            " minimal number of screen lines to keep above and below the cursor
set showcmd                " show (partial) command in the last line of the screen
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
set nohlsearch             " do not highlight matches of previous search pattern
set gdefault               " turn on the ':substitute' flag 'g' by default
set backspace=indent,eol,start  " allow backspacing over everything in insert mode
set encoding=utf-8              " sets the character encoding used inside Vim
set fileencodings=utf8,cp1251   " list of character encodings considered
                                " when starting to edit an existing file
set fillchars=vert:\ ,fold:-    " characters for fill statuslines and vertical separators
set listchars=tab:⇥\ ,trail:·,extends:⋯,precedes:⋯,eol:¬  " invisible symbols representation
set list                   " display unprintable characters by default
set wildignore+=.git,*.o,*.pyc,.DS_Store  " list of ignored in expanding wildcards files
set nobackup               " do not create backup files
set noswapfile             " do not create swap files
set splitright             " how to split new windows
set equalalways            " makes sure Vim try to make all windows equal
set winminheight=0         " non-current windows may collapse to a status line and nothing else

set exrc                   " execute project-specific settings
set secure                 " disable unsafe commands in your project-specific settings


" GUI settings ------------------------------------------------------------------------------------
if has('gui_running')
	set lines=999 columns=999  " maximize window

	set guioptions-=T          " turn off toolbar
	set guioptions-=rL         " turn off scrolls (both right and left)

	" font setup
	set guifont=Sauce\ Code\ Powerline:h10
	set antialias

	" cursor setup
	set guicursor=n-v-c:block-Cursor
	set guicursor+=i:ver15-iCursor
	set guicursor+=n-v-c:blinkon0
endif


" Setup colorscheme -------------------------------------------------------------------------------
set background=light       " Vim will try to use colors that look good on a light background
try
	colorscheme solarized  " try to setup colorscheme

	" non-visible characters colors
	highlight NonText    term=NONE cterm=NONE gui=NONE ctermfg=15 ctermbg=15 guifg=#e7e7cf guibg=#fdf6e3
	highlight SpecialKey term=NONE cterm=NONE gui=NONE ctermfg=15 ctermbg=15 guifg=#e7e7cf guibg=#fdf6e3

	if has('gui_running')
		" cursor colors
		highlight Cursor  guifg=#fdf6e3 guibg=#839496
		highlight iCursor guifg=NONE    guibg=#cb4b16

		au InsertEnter * highlight Cursor guifg=#fdf6e3 guibg=#cb4b16
		au InsertLeave * highlight Cursor guifg=#fdf6e3 guibg=#839496
	endif
catch /^Vim\%((\a\+)\)\=:E185/
	" cannot find color scheme
endtry


" Statusline setup --------------------------------------------------------------------------------
function! StatusLineSetup(active)
	if &buftype == 'quickfix' || &buftype == 'nofile'
		let &l:statusline = "%<%f"
	elseif a:active
		let &l:statusline = "%<%f\ %m%r\%=\ %Y\ \|\ %{&fenc==\"\"?&enc:&fenc}\ \|\ %{&ff}\ \|\ %l:%v\ \|\ %P\ "
	else
		let &l:statusline = "%<%f%=%P\ "
	endif
endfunction
autocmd BufEnter * call StatusLineSetup(1)
autocmd BufLeave * call StatusLineSetup(0)
autocmd WinEnter * call StatusLineSetup(1)
autocmd WinLeave * call StatusLineSetup(0)


" Ack plugin setup --------------------------------------------------------------------------------
let g:ackhighlight = 1   " highlight the searched term


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
let g:PyFlakeOnWrite = 0


" CloseTag plugin setup ---------------------------------------------------------------------------
let g:closetag_filenames = "*.html"


" Lexima plugin setup -----------------------------------------------------------------------------
let g:lexima_enable_basic_rules = 1
let g:lexima_enable_newline_rules = 1
let g:lexima_enable_endwise_rules = 1


" Ctags plugin setup ------------------------------------------------------------------------------
let g:vim_tags_auto_generate = 0  " do not generate tags on file saving
let g:vim_tags_ctags_binary = '/usr/local/bin/ctags'



" Keys remapping ----------------------------------------------------------------------------------
" nnoremap ; :
" let mapleader=','

" current file directory expand (see http://vimcasts.org/episodes/the-edit-command/)
cnoremap %% <C-R>=expand('%:h').'/'<CR>

" emacs style jump to end of line
nmap <C-a> ^
nmap <C-e> $
imap <C-a> <C-o>I
imap <C-e> <C-o>A

" Ctrl+Tab to search in buffers
map <C-tab> :CtrlPBuffer<CR>

" lines 'bubbling' (see http://vimcasts.org/episodes/bubbling-text/)
nmap <C-Up> [e
vmap <C-Up> [egv
nmap <C-Down> ]e
vmap <C-Down> ]egv
