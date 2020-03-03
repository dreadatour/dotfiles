if has("macunix")
	let g:python_host_prog = '/usr/local/bin/python'
	let g:python3_host_prog = '/usr/local/bin/python3'
endif

" Plugin manager ----------------------------------------------------------------------------------
" specify a directory for plugins
call plug#begin('~/.config/nvim/plugged')

" a fixed solarized colorscheme for better truecolor support
Plug 'icymind/NeoSolarized'

" enhanced netrw
Plug 'tpope/vim-vinegar'

" pairs of handy bracket mappings
Plug 'tpope/vim-unimpaired'

" highlights the word under the cursor
" Plug 'dreadatour/vim-cursorword'

" auto close parentheses
Plug 'cohama/lexima.vim'

" use RipGrep in Vim and display results in a quickfix list
Plug 'jremmen/vim-ripgrep'

" fuzzy file, buffer, mru, tag, etc finder
Plug 'ctrlpvim/ctrlp.vim'

" plugin to show git diff in the gutter (sign column) and stages/undoes hunks
" Plug 'airblade/vim-gitgutter'

" lean & mean status/tabline
Plug 'vim-airline/vim-airline'

" Go development plugin
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" TypeScript development plugin
Plug 'HerringtonDarkholme/yats.vim'
Plug 'mhartington/nvim-typescript', { 'do': './install.sh' }

" Install completion engine
Plug 'neoclide/coc.nvim', {'branch': 'release', 'do': 'yarn install --frozen-lockfile'}

" asynchronous lint engine
Plug 'w0rp/ale'

" initialize plugin system
call plug#end()


" Base settings -----------------------------------------------------------------------------------
source ~/.vimrc            " load base vim config
set termguicolors          " use 24-bit colors

set completeopt-=preview   " do not preview complete options in Scratch buffer


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


" Keys remapping ----------------------------------------------------------------------------------
" current file directory expand (see http://vimcasts.org/episodes/the-edit-command/)
cnoremap %% <C-R>=expand('%:h').'/'<CR>

" go to window upper
imap <C-k> <Esc><C-W>ka
nmap <C-k> <C-W>k

" go to window below
imap <C-j> <Esc><C-W>ja
nmap <C-j> <C-W>j

" go to left window
imap <C-h> <Esc><C-W>ha
nmap <C-h> <C-W>h

" go to right window
imap <C-l> <Esc><C-W>la
nmap <C-l> <C-W>l

" emacs style jump to end of line
nmap <C-a> ^
nmap <C-e> $
vmap <C-a> ^
vmap <C-e> $
imap <C-a> <C-o>I
imap <C-e> <C-o>A
cnoremap <C-a> <Home>
cnoremap <C-e> <End>


" Useful hooks ------------------------------------------------------------------------------------
" remove trailing whitespaces on save
"autocmd FileType css,javascript,go,html,python,typescript autocmd BufWritePre <buffer> :%s/\s\+$//e


" Netrw setup -------------------------------------------------------------------------------------
" disable banner
let g:netrw_banner=0


" Solarized color scheme --------------------------------------------------------------------------
try
	" set colorsheme
	colorscheme NeoSolarized

	" show vertical split column
	let g:neosolarized_vertSplitBgTrans = 0

	" non-visible characters colors
	highlight NonText    term=NONE cterm=NONE gui=NONE ctermfg=15 ctermbg=15 guifg=#e7e7cf guibg=#fdf6e3
	highlight SpecialKey term=NONE cterm=NONE gui=NONE ctermfg=15 ctermbg=15 guifg=#e7e7cf guibg=#fdf6e3
catch /^Vim\%((\a\+)\)\=:E185/
	" cannot find color scheme
endtry


" GitGutter plugin --------------------------------------------------------------------------------
" disable gitgutter by default
"let g:gitgutter_enabled = 0
" sign column shouldn't look like the line number column, use default background color instead
"let g:gitgutter_override_sign_column_highlight = 0


" Lexima plugin setup -----------------------------------------------------------------------------
let g:lexima_enable_basic_rules = 1
let g:lexima_enable_newline_rules = 1
let g:lexima_enable_endwise_rules = 1


" RipGrep plugin setup ----------------------------------------------------------------------------
" highlight search results
let g:rg_highlight = 1


" CtrlP plugin settings ---------------------------------------------------------------------------
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_max_files = 0  " set no max file limit

if executable('rg')
	set grepprg=rg\ --color=never

	let g:ackprg = 'rg --vimgrep --no-heading'

	let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'  " use ripgrep in CtrlP for listing files
	let g:ctrlp_use_caching = 0                            " ag is fast enough that CtrlP doesn't need to cache
endif

" Ctrl+Tab to search in buffers
map <C-tab> :CtrlPBuffer<CR>


" Airline plugin ----------------------------------------------------------------------------------
" enable integration with airline
let g:airline#extensions#ale#enabled = 1


" Go lang plugin ----------------------------------------------------------------------------------
" code highlighting
let g:go_highlight_build_constraints = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_structs = 1
let g:go_highlight_types = 1

" do not highlight same variables
let g:go_auto_sameids = 0

" autoimport dependencies
let g:go_fmt_command = "goimports"

" show types and definitions in statusline
let g:go_auto_type_info = 1

" JSON tags to structs use camel case
let g:go_addtags_transform = "camelcase"

" disable vim-go :GoDef short cut (gd)
" this is handled by LanguageClient [LC]
let g:go_def_mapping_enabled = 0


" Coc plugin --------------------------------------------------------------------------------------
set hidden         " if hidden is not set, TextEdit might fail
set nobackup       " some servers have issues with backup files, see #649
set nowritebackup
set cmdheight=2    " better display for messages
set updatetime=300 " will have bad experience for diagnostic messages when it's default 4000
set shortmess+=c   " don't give |ins-completion-menu| messages.
set signcolumn=yes " always show signcolumns

" Use tab for trigger completion with characters ahead and navigate.
inoremap <silent><expr> <TAB>
    \ pumvisible() ? "\<C-n>" :
    \ <SID>check_back_space() ? "\<TAB>" :
    \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" use <c-space> to trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

" use <cr> to confirm completion, `<C-g>u` means break undo chain at current position
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" create mappings for function text object, requires document symbols feature of languageserver
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" use <C-d> for select selections ranges, needs server support, like: coc-tsserver, coc-python
nmap <silent> <C-d> <Plug>(coc-range-select)
xmap <silent> <C-d> <Plug>(coc-range-select)

" use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" using CocList
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>  " show all diagnostics
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>   " manage extensions
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>     " show commands
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>      " find symbol of current document
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>   " search workspace symbols
nnoremap <silent> <space>j  :<C-u>CocNext<CR>              " do default action for next item
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>              " do default action for previous item
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>        " resume latest coc list


" Ale plugin --------------------------------------------------------------------------------------
let g:ale_shell = '/bin/sh'    " use sh shell
let g:ale_open_list = 0        " do not show window on errors

" error, warning and info signs
let g:ale_sign_error = '⤫'
let g:ale_sign_warning = '⚠'
let g:ale_sign_info = '⚠'

" lint on save only
let g:ale_lint_on_enter = 0                 " do not lint on enter the buffer
let g:ale_lint_on_filetype_changed = 0      " do not lint on filetype change
let g:ale_lint_on_insert_leave = 0          " do not lint on leave insert mode
let g:ale_lint_on_text_changed = 'never'    " do not lint on text change
let g:ale_lint_on_save = 1                  " lint on save
let g:ale_fix_on_save = 1                   " fix issues on save

" golangci-lint linter options
let g:ale_go_golangci_lint_options = ''

" typescript tslint linter options
let g:ale_typescript_tslint_use_global = 0
let g:ale_typescript_tslint_config_path = 'tslint.json'

" list of linters
let g:ale_linters = {
\	'go': ['golangci-lint'],
\	'typescriptreact': ['tslint'],
\}

" list of fixers
let g:ale_fixers = {
\	'*': ['remove_trailing_lines', 'trim_whitespace'],
\	'typescriptreact': ['tslint', 'remove_trailing_lines', 'trim_whitespace'],
\}
"\	'javascript': ['prettier', 'eslint'],
"\	'javascriptreact': ['prettier', 'eslint'],
"\	'typescript': ['prettier', 'eslint', 'tslint'],
