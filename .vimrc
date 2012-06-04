" use Vim settings, rather then Vi settings (much better!)
" this must be first, because it changes other options as a side effect
set nocompatible


"""" Pathogen settings """"""""""""""""""""""""""""""""""""""""""""""""""""""""
" speedup pathogen loading by temporarily disabling file type detection
filetype off

" add all plugins in ~/.vim/bundle/ to runtimepath (vim-pathogen)
if filereadable($HOME."/.vim/autoload/pathogen.vim")
	call pathogen#infect()
	call pathogen#helptags()
endif

" turn on syntax highlighting
if !exists("syntax_on")
	syntax on
endif

" turn file type detection back on
filetype plugin indent on


"""" Some simple stuff """"""""""""""""""""""""""""""""""""""""""""""""""""""""
set showcmd          " display incomplete commands
set incsearch        " do incremental searching
set hlsearch         " highlight searching results
set number           " show line numbers
set cursorline       " show cursor line
set nowrap           " turn off line wrap
set gdefault         " always global regex
set nobackup         " do not create backup files
set noswapfile       " do not create swap files
set wildmenu         " turn on wildmenu
set wcm=<Tab>        " wildmenu navigation key
set laststatus=2     " status line is always visible
set winminheight=0   " minimum window height (FIXME)
set scrolloff=3      " lines count around cursos
set background=dark  " we want dark and scary interface

" tabulation settings
set tabstop=4
set shiftwidth=4
set smarttab
set softtabstop=4
set autoindent

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" set file encodings
set encoding=utf-8
set fileencodings=utf8,cp1251

" set global list of ignores files
set wildignore+=.git,*.o,*.pyc,.DS_Store

" chars for fill statuslines and vertical separators
set fillchars=vert:\ ,fold:-

" these settings are only for gvim
if has("gui_running")
	set guioptions-=T   " turn off toolbar
	set guioptions-=rL  " turn off scrolls (both right and left)

	" font setup
	set guifont=Menlo:h14

	" try to setup colorsheme
	try
		colorscheme solarized
		" reload 'mark' plugin after colorscheme changed
		if filereadable($HOME."/.vim/plugin/mark.vim")
			source ~/.vim/plugin/mark.vim
		endif
	catch /^Vim\%((\a\+)\)\=:E185/
		" pass
	endtry

	" chars for showing inwisible symbols
	set listchars=tab:▸\ ,eol:¬,trail:·,extends:»
	" set list ON by default
	set list
else
	" chars for showing inwisible symbols
	set listchars=tab:>>,eol:$,trail:.
endif


"""" Statusline setup """""""""""""""""""""""""""""""""""""""""""""""""""""""""
" active statusline
function! SetActiveStatusLine()
	if exists("*GitBranchInfoTokens")
		let &l:statusline = "%<%f\ %m%r\ %{GitBranchInfoTokens()[0]}\%=\ %Y\ \|\ %{&fenc==\"\"?&enc:&fenc}\ \|\ %{&ff}\ \|\ %l,%v\ %P"
	else
		let &l:statusline = "%<%f\ %m%r\%=\ %Y\ \|\ %{&fenc==\"\"?&enc:&fenc}\ \|\ %{&ff}\ \|\ %l,%v\ %P"
	endif
endfunction
autocmd BufEnter * call SetActiveStatusLine()
autocmd WinEnter * call SetActiveStatusLine()

" inactive statusline
autocmd WinLeave * let &l:statusline = '%<%f'


"""" Keys remapping """""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap ; :

" current file directory expand (http://vimcasts.org/episodes/the-edit-command/)
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%

" emacs style jump to end of line
imap <C-e> <C-o>A
imap <C-a> <C-o>I

" Ctrl+Tab switch buffers, Ctrl+Shift+Tab switch buffers back
map <C-tab> :bnext<cr>
map <C-S-tab> :bprevious<cr>

" these settings are only for gvim
if has("gui_running")
	" easy indentation
	nmap <D-[> <<
	nmap <D-]> >>
	vmap <D-[> <gv
	vmap <D-]> >gv
endif


"""" Leader key workaround """"""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader=','

" Show list status
function! ShowList()
	if &l:list | echon 'list = ON' | else | echon 'list = OFF' | endif
endfunction

" Show wrap status
function! ShowWrap()
	if &l:wrap | echon 'wrap = ON' | else | echon 'wrap = OFF' | endif
endfunction

" Show ignore case status
function! ShowIgnoreCase()
	if &l:ignorecase | echon 'search ignorecase = ON' | else | echon 'search ignorecase = OFF' | endif
endfunction

" Show number status
function! ShowNumber()
	if &l:number | echon 'number = ON' | else | echon 'number = OFF' | endif
endfunction

" Show highlight search status
function! ShowHighlightSearch()
	if &l:hls | echon 'search highlight = ON' | else | echon 'search highlight = OFF' | endif
endfunction

" toggle 'set list' (http://vimcasts.org/episodes/show-invisibles/)
nmap <silent> <leader>l :set list!<CR>:call ShowList()<CR>

" toggle 'set wrap'
nmap <silent> <leader>w :set wrap!<CR>:call ShowWrap()<CR>

" toggle 'set ignorecase'
nmap <silent> <leader>i :set ignorecase!<CR>:call ShowIgnoreCase()<CR>

" toggle 'set number'
nmap <silent> <leader>u :set number!<CR>:call ShowNumber()<CR>

" toggle 'set hls'
nmap <silent> <leader>H :set hls!<CR>:call ShowHighlightSearch()<CR>
nmap <silent> <leader>h :nohlsearch<CR>  " FIXME

" setup plugins call with leader key
map <leader>f :NERDTreeToggle<CR>
map <leader>t :TagbarToggle<CR>
map <leader>c :VimCommanderToggle<CR>


"""" Plugins personal settings """"""""""""""""""""""""""""""""""""""""""""""""
" tagbar width
let g:tagbar_width = 31

" the message when there is no Git repository on the current dir
let g:git_branch_status_nogit=''

" switch buffers with Ctrl+Tab (minibufexplorer feature) (FIXME)
let g:miniBufExplMapCTabSwitchBufs = 1

" disable pylint checking every save
let g:pymode_lint_write = 0
" disable auto open cwindow if errors be finded
let g:pymode_lint_cwindow = 0


"""" Autocomplete settings """"""""""""""""""""""""""""""""""""""""""""""""""""
" autocomplete with <Tab> key
function InsertTabWrapper()
	let col = col('.') - 1
	if !col || getline('.')[col - 1] !~ '\k'
		return "\<tab>"
	else
		return "\<c-p>"
	endif
endfunction
imap <tab> <c-r>=InsertTabWrapper()<cr>

" setup autocomplete sources: current buffer + dictionary + other buffers + tags
set complete=".kbt"

" taglist settings
let g:tagbar_ctags_bin='/usr/local/Cellar/ctags/5.8/bin/ctags'
let g:tagbar_autoclose=1


"""" Load local vim settings (current directory only) """""""""""""""""""""""""
function SetLocalOptions(fname)
    let dirname = fnamemodify(a:fname, ":p:h")
    while "/" != dirname
        let lvimrc  = dirname . "/.lvimrc"
        if filereadable(lvimrc)
            execute "source " . lvimrc
            break
        endif
        let dirname = fnamemodify(dirname, ":p:h:h")
    endwhile
endfunction
au BufNewFile,BufRead * call SetLocalOptions(bufname("%"))


"""" ToDo list """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: different buffer list for each tabs
"       http://stackoverflow.com/questions/2308278/how-to-have-a-different-buffer-list-for-each-tabs-in-vim
" TODO: neocomplcache is a good plugin for auto-completion
"       https://github.com/Shougo/neocomplcache
" TODO: add more vim plugins:
"       https://github.com/mileszs/ack.vim
"       https://github.com/majutsushi/tagbar
"       https://github.com/tpope/vim-fugitive
"       https://github.com/tpope/vim-surround
"       https://github.com/klen/python-mode
"       https://github.com/fholgado/minibufexpl.vim
