"""" GUI settings """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set lines=999 columns=999  " maximize window

set guioptions-=T          " turn off toolbar
set guioptions-=rL         " turn off scrolls (both right and left)

" font setup
set guifont=Sauce\ Code\ Powerline:h10
set antialias


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
