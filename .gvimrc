" turn off toolbar
set guioptions-=T

" set 'desert' colorscheme
colorscheme desert256
source ~/.vim/plugin/mark.vim

" set font and fontsize
set guifont=Consolas:h14

" Chars for showing inwisible symbols
set listchars=tab:▸\ ,eol:¬,trail:·,extends:»

" Set list ON
set list

" Only do this part when compiled with support for autocommands
"if has("autocmd")
"	autocmd GUIEnter * call VimCommanderToggle()
"endif

" Go to previous tab
imap <D-Left> <Esc>:tabp<CR>a
nmap <D-Left> :tabp<CR>

" Go to next tab
imap <D-Right> <Esc>:tabn<CR>a
nmap <D-Right> :tabn<CR>

" Go to previous window and maximize it
imap <D-Up> <Esc><C-W>k<C-W>_a
nmap <D-Up> <C-W>k<C-W>_

" Go to next window and maximize it
imap <D-Down> <Esc><C-W>j<C-W>_a
nmap <D-Down> <C-W>j<C-W>_

" Tabs switching
map <D-1> 1gt
map <D-2> 2gt
map <D-3> 3gt
map <D-4> 4gt
map <D-5> 5gt
map <D-6> 6gt
map <D-7> 7gt
map <D-8> 8gt
map <D-9> 9gt
map <D-0> :tablast<CR>

" Emacs style jump to end of line
imap <C-e> <C-o>A
imap <C-a> <C-o>I

" Easy indentation
nmap <D-[> <<
nmap <D-]> >>
vmap <D-[> <gv
vmap <D-]> >gv

