" Add all plugins in ~/.vim/bundle/ to runtimepath (vim-pathogen)
call pathogen#infect()
call pathogen#helptags()

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" Allow backspacing over everything in insert mode
set backspace=indent,eol,start

set showcmd         " display incomplete commands
set incsearch       " do incremental searching
set hlsearch        " highlight searching results
set number          " show line numbers
set cursorline      " show cursor line
set nowrap          " turn off line wrap

let g:git_branch_status_nogit=""          " the message when there is no Git repository on the current dir
hi User1 guifg=#9fd7fe guibg=#c2bfa5

set statusline=%<%f\ %m%r\ %1*%{GitBranchInfoTokens()[0]}%*\%=\ %Y\ \|\ %{&fenc==\"\"?&enc:&fenc}\ \|\ %{&ff}\ \|\ %l,%v\ %P
set laststatus=2    " status line is always visible
set winminheight=0  " minimum window height
set scrolloff=3     " lines count around cursos

" Chars for showing inwisible symbols
"set listchars=tab:>>,eol:$,trail:.

" Tagbar width
let g:tagbar_width = 31

" Turn on syntax highlighting
if !exists("syntax_on")
    syntax on
endif

" Tabulation settings
set tabstop=4
set shiftwidth=4
set smarttab
set softtabstop=4
set autoindent

" Turn off SWP and ~ files
set nobackup
set noswapfile

" Turn on wildmenu
set wildmenu
set wcm=<Tab>

set encoding=utf-8              " Default file encoding
set fileencodings=utf8,cp1251   " If file is not UTF, try CP1251 encoding

" Current file directory expand (http://vimcasts.org/episodes/the-edit-command/)
let mapleader=','
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%

map <leader>f :NERDTreeToggle<cr>
map <leader>t :TagbarToggle<cr>

" Toggle 'set list' (http://vimcasts.org/episodes/show-invisibles/)
nmap <silent> <leader>l :set list!<CR>:call ShowList()<CR>
" Toggle 'set wrap'
nmap <silent> <leader>w :set wrap!<CR>:call ShowWrap()<CR>
" Toggle 'set ignorecase'
nmap <silent> <leader>i :set ignorecase!<CR>:call ShowIgnoreCase()<CR>
" Toggle 'set number'
nmap <silent> <leader>u :set number!<CR>:call ShowNumber()<CR>
" Toggle 'set hls'
nmap <silent> <leader>h :set hls!<CR>:call ShowHighlightSearch()<CR>

menu GoTo.mpop       :lcd ~/work/mpop/<CR>
menu GoTo.emailru    :lcd ~/work/e.mail.ru/<CR>
menu GoTo.deploy     :lcd ~/work/deploy/<CR>
menu GoTo.mcalendar  :lcd ~/work/mcalendar/<CR>
menu GoTo.temp       :lcd ~/temp/<CR>
nmap <silent> <leader>g :emenu GoTo.<Tab>

" Emacs style jump to end of line
imap <C-e> <C-o>A
imap <C-a> <C-o>I

" Easy indentation
nmap <D-[> <<
nmap <D-]> >>
vmap <D-[> <gv
vmap <D-]> >gv

" Change encoding and EOL
menu FileFormat.cp1251 :e   ++enc=cp1251<CR>
menu FileFormat.koi8-r :e   ++enc=koi8-r<CR>
menu FileFormat.cp866  :e   ++enc=ibm866<CR>
menu FileFormat.utf-8  :e   ++enc=utf-8<CR>
menu FileFormat.unix   :set fileformat=unix<CR>
menu FileFormat.dos    :set fileformat=dos<CR>
menu FileFormat.mac    :set fileformat=mac<CR>
map <F8> :emenu FileFormat.<Tab>

noremap <silent> <leader>c :cal VimCommanderToggle()<CR> 
" map <F12> :VSTreeExplore <CR>

" Show list status
function! ShowList()
	if &l:list
		echon 'list = ON'
	else
		echon 'list = OFF'
	endif
endfunction

" Show wrap status
function! ShowWrap()
	if &l:wrap
		echon 'wrap = ON'
	else
		echon 'wrap = OFF'
	endif
endfunction

" Show ignore case status
function! ShowIgnoreCase()
	if &l:ignorecase
		echon 'search ignorecase = ON'
	else
		echon 'search ignorecase = OFF'
	endif
endfunction

" Show number status
function! ShowNumber()
	if &l:number
		echon 'number = ON'
	else
		echon 'number = OFF'
	endif
endfunction

" Show highlight search status
function! ShowHighlightSearch()
	if &l:hls
		echon 'search highlight = ON'
	else
		echon 'search highlight = OFF'
	endif
endfunction

" current directory only options in file .lvimrc
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

" Aвтозавершение слов по tab
function InsertTabWrapper()
 let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-p>"
  endif
endfunction
imap <tab> <c-r>=InsertTabWrapper()<cr>

" Слова откуда будем завершать
set complete=""
" Из текущего буфера
set complete+=.
" Из словаря
set complete+=k
" Из других открытых буферов
set complete+=b
" из тегов
set complete+=t

" TagList settings
let g:tagbar_ctags_bin='/usr/local/Cellar/ctags/5.8/bin/ctags'
let g:tagbar_autoclose=1

