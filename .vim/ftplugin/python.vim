" indent settings for python
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal smarttab
setlocal expandtab

" highlight text over 80 characters
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%80v.\+/

" strip trailing whitespaces on save file
autocmd BufWrite *.py silent! %s/\s\+$//ge
