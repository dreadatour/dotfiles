"""" GUI settings """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set guioptions-=T   " turn off toolbar
set guioptions-=rL  " turn off scrolls (both right and left)

" font setup
set guifont=Menlo:h14

" chars for showing inwisible symbols
set listchars=tab:▸\ ,eol:¬,trail:·,extends:»
" set list ON by default
set list


"""" Keys remapping """""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" easy indentation
nmap <D-[> <<
nmap <D-]> >>
vmap <D-[> <gv
vmap <D-]> >gv

" go to previous window
imap <D-Up> <Esc><C-W>ka
nmap <D-Up> <C-W>k

" go to next window
imap <D-Down> <Esc><C-W>ja
nmap <D-Down> <C-W>j

" go to left window
imap <D-Left> <Esc><C-W>ha
nmap <D-Left> <C-W>h

" go to right window
imap <D-Right> <Esc><C-W>la
nmap <D-Right> <C-W>l
