" Python specific settings ----------------------------------------------------

" indent style
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal expandtab
setlocal autoindent

let python_highlight_all = 1                   " enable all syntax highlighting features
let b:comment_leader = '#'                     " set python style comment

highlight BadWhitespace ctermfg=red guifg=red  " use the below highlight group when displaying bad whitespace is desired.
match BadWhitespace /^\t\+/                    " display tabs at the beginning of a line in Python mode as bad.
match BadWhitespace /\s\+$/                    " make trailing whitespace be flagged as bad.

" remove trailing whitespaces before save
autocmd BufWritePre * %s/\s\+$//e
