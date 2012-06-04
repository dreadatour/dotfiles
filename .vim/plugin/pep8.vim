if exists("g:pep8_loaded")
	finish
endif
let g:pep8_loaded = 1

command Pep8 call <SID>Pep8()

if !hasmapto(':Pep8<CR>')
	silent! nnoremap <unique> <silent> <Leader>p :Pep<CR>
endif

function s:Pep8()
	set lazyredraw
	" Close any existing cwindows.
	cclose
	let l:grepformat_save = &grepformat
	let l:grepprogram_save = &grepprg
	set grepformat&vim
	set grepformat&vim
	let &grepformat = '%f:%l:%m'
	let &grepprg = 'pep8 --repeat'
	if &readonly == 0 | update | endif
	silent! grep! %
	let &grepformat = l:grepformat_save
	let &grepprg = l:grepprogram_save
	" Open cwindow
	execute 'belowright copen'
	" Resize window - from 4 to 10 lines
	exe max([min([line("$"), 10]), 4]) . "wincmd _"
	nnoremap <buffer> <silent> c :cclose<CR>
	nnoremap <buffer> <silent> q :cclose<CR>
	set nolazyredraw
	redraw!
	let tlist=getqflist()
	if empty(tlist)
		if !hlexists('GreenBar')
			hi GreenBar term=reverse ctermfg=white ctermbg=darkgreen guifg=white guibg=darkgreen
		endif
		echohl GreenBar
		echomsg "PEP8 correct"
		echohl None
		cclose
	endif
endfunction

