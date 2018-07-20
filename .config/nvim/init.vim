if has("macunix")
	let g:python_host_prog = '/usr/local/bin/python'
	let g:python3_host_prog = '/usr/local/bin/python3'
endif

" Plugin manager ----------------------------------------------------------------------------------
" specify a directory for plugins
call plug#begin('~/.config/nvim/plugged')

" a fixed solarized colorscheme for better truecolor support
Plug 'icymind/NeoSolarized'

" plugin to dim inactive windows
Plug 'blueyed/vim-diminactive'

" enhanced netrw
Plug 'tpope/vim-vinegar'

" pairs of handy bracket mappings
Plug 'tpope/vim-unimpaired'

" auto close (X)HTML tags
Plug 'alvan/vim-closetag'

" Sublime Text style multiple selections
Plug 'terryma/vim-multiple-cursors'

" highlights the word under the cursor
Plug 'dreadatour/vim-cursorword'

" auto close parentheses
Plug 'cohama/lexima.vim'

" use RipGrep in Vim and display results in a quickfix list
Plug 'jremmen/vim-ripgrep'

" fuzzy file, buffer, mru, tag, etc finder
Plug 'ctrlpvim/ctrlp.vim'

" plugin to show git diff in the gutter (sign column) and stages/undoes hunks
Plug 'airblade/vim-gitgutter'

" plugin to toggle, display and navigate marks
Plug 'kshenoy/vim-signature'

" lean & mean status/tabline
Plug 'vim-airline/vim-airline'

" asynchronous lint engine
Plug 'w0rp/ale'

" asynchronous completion framework
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" deoplete source for Go
Plug 'zchee/deoplete-go', { 'do': 'make'}

" Go development plugin
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" Plug 'itchyny/vim-parenmatch'
" Plug 'mileszs/ack.vim'
" Plug 'ervandew/supertab'

" initialize plugin system
call plug#end()


" Base settings -----------------------------------------------------------------------------------
source ~/.vimrc            " load base vim config
set termguicolors          " use 24-bit colors


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


" Netrw setup -------------------------------------------------------------------------------------
" disable banner
let g:netrw_banner=0


" Solarized color scheme --------------------------------------------------------------------------
" set colorsheme
colorscheme NeoSolarized

" show vertical split column
let g:neosolarized_vertSplitBgTrans = 0

" non-visible characters colors
highlight NonText    term=NONE cterm=NONE gui=NONE ctermfg=15 ctermbg=15 guifg=#e7e7cf guibg=#fdf6e3
highlight SpecialKey term=NONE cterm=NONE gui=NONE ctermfg=15 ctermbg=15 guifg=#e7e7cf guibg=#fdf6e3


" GitGutter plugin --------------------------------------------------------------------------------
" sign column shouldn't look like the line number column, use default background color instead
let g:gitgutter_override_sign_column_highlight = 0


" CloseTag plugin setup ---------------------------------------------------------------------------
let g:closetag_filenames = "*.html"


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


" Ale plugin --------------------------------------------------------------------------------------
" error and warning signs
let g:ale_sign_error = '⤫'
let g:ale_sign_warning = '⚠'

" Airline plugin ----------------------------------------------------------------------------------
" enable integration with airline
let g:airline#extensions#ale#enabled = 1


" Deoplete plugin ---------------------------------------------------------------------------------
" enable deoplete on startup
let g:deoplete#enable_at_startup = 1

" disable deoplete when in multi cursor mode
function! Multiple_cursors_before()
    let b:deoplete_disable_auto_complete = 1
endfunction
function! Multiple_cursors_after()
    let b:deoplete_disable_auto_complete = 0
endfunction


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

" highlight same variables
let g:go_auto_sameids = 1

" autoimport dependencies
let g:go_fmt_command = "goimports"

" show types and definitions in statusline
let g:go_auto_type_info = 1

" JSON tags to structs use camel case
let g:go_addtags_transform = "camelcase"
