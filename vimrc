"| |  / /   |  / | / / ____/ /   /  _/ ____/ ____/
"| | / / /| | /  |/ / /   / /    / // __/ / /_
"| |/ / ___ |/ /|  / /___/ /____/ // /___/ __/
"|___/_/  |_/_/ |_/\____/_____/___/_____/_/
"
"" repo  : https://github.com/vanclief/dotfiles-arch/
" file  : vimrc

" Check if is NVIM
let is_nvim = has('nvim')

" Set one dark theme
syntax on
" colorscheme github-light

"Toggle nerdtree with ctrl + n
let g:NERDTreeWinPos="left"
map <C-n> :NERDTreeToggle<CR>
autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Escape using jj
imap jj <ESC>

" Testing
nmap <silent> <leader>t :TestNearest<CR>
nmap <silent> <leader>T :TestFile<CR>

" Go testing
let test#go#runner = 'ginkgo'

" Go mappings
au FileType go nmap <leader>t <Plug>(go-test-func)

" Go syntax highlighting
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_variable_declarations = 1
let g:go_highlight_variable_assignments = 1
let g:go_highlight_types = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_operators = 1

" Go auto formatting and importing
let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"

" If its nvim load its config file
if is_nvim
  source "~/dotfiles-local/nvim/init.vim"
endif
