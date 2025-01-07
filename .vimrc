" Set <space> as the leader key.
let mapleader = " "
" Enable relative line numbers.
set relativenumber
" Sync clipboard between the OS and Vim.
set clipboard=unnamedplus
" Save undo history.
set undofile " FIXME: It does not work!
" Case insensitive searching UNLESS /C or capital in search.
set ignorecase
set smartcase
" Enable true color support.
set termguicolors
" Sets the fillchars to space.
set fillchars+=eob:\ 

" Move line(s) down in visual mode.
vnoremap J :m '>+1<CR>gv=gv
" Move line(s) up in visual mode.
vnoremap K :m '<-2<CR>gv=gv
" Keep the cursor in the middle during 1/2 page jumping (downwards).
nnoremap <C-d> <C-d>zz
" Keep the cursor in the middle during 1/2 page jumping (upwards).
nnoremap <C-u> <C-u>zz
" Clear search highlight on pressing Esc.
nnoremap <Esc> :nohlsearch<CR><Esc>

call plug#begin()
" Highlight copied text.
Plug 'machakann/vim-highlightedyank'
" Commenting plugin.
Plug 'tpope/vim-commentary'
" Allow to jump to any positions in the visible editor area.
Plug 'justinmk/vim-sneak' " TODO: Try to make it behave like the neovim plugin called leap!
" Delete, change, add parentheses, quotes, XML-tags wiars+=eob:\ rs+=eob:\ h ease.
Plug 'tpope/vim-surround'

Plug 'terryma/vim-multiple-cursors'
" Fast left-right movement in Vim.
Plug 'unblevable/quick-scope' " FIXME: It does not work!
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']
" Colorscheme.
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
call plug#end()

colorscheme catppuccin_mocha
