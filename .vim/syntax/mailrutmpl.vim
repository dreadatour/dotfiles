" Vim syntax file
" Language:	Mail.Ru HTML template
" Maintainer:	Vladimir Rudnyh <rudnyh@corp.mail.ru>
" Last Change:	2011 Sep 29

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

if !exists("main_syntax")
  let main_syntax = 'html'
endif

if version < 600
  so <sfile>:p:h/html.vim
else
  runtime! syntax/html.vim
  unlet b:current_syntax
endif

syn cluster mailruBlocks add=mailruVar,mailruTag

syn region mailruVar start="##" end="##" containedin=ALLBUT,@mailruBlocks
syn region mailruTag start="<!--\s*\(/\?IF\|ELSIF\|ELSE\|/\?FOR\|INCLUDE\)" end="-->" containedin=ALLBUT,@mailruBlocks

command -nargs=+ MailruHiLink hi def link <args>
  MailruHiLink mailruVar Identifier
  MailruHiLink mailruTag Identifier
delcommand MailruHiLink

let b:current_syntax = "mailrutmpl"

