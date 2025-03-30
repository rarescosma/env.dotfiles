" A minimal vimrc for new vim users to start with.
"
" Referenced here: http://vimuniversity.com/samples/your-first-vimrc-should-be-nearly-empty
"
"
" Original Author:       Bram Moolenaar <bram@vim.org>
" Made more minimal by:  Ben Orenstein
" Customized by:         Rareș Cosma
"

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

filetype plugin indent on   " Enable file type detection and do language-dependent indenting.
syntax on                   " Switch syntax highlighting on.

" Common settings.
source ~/.config/nvim/common.vim

set expandtab               " Use spaces instead of tabs.
set smartindent             " Smart indent.
set tabstop=4 softtabstop=4 " Tab key indents by 4 spaces.
set shiftwidth=4            " >> indents by 4 spaces.
set backspace=indent,eol,start " Make backspace behave in a sane manner.
set hidden                  " Switch between buffers without having to save first.

" GUI.
set laststatus=2            " Always show statusline.
set display=lastline        " Show as much as possible of the last line.
set showcmd                 " Show already typed keys when more are expected.
set lazyredraw              " Only redraw when necessary.
set cursorline              " Find the current line quickly.
set report=0                " Always report changed lines.
set synmaxcol=200           " Only highlight the first 200 columns.
set listchars=nbsp:¬,extends:»,precedes:«,trail:•,eol:¶   " Show those damn hidden characters
set scrolloff=3             " Display a couple of lines of context.
set nolinebreak
set termguicolors
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_invert_selection = '0'
let g:gruvbox_italic = '1'
colorscheme gruvbox

" File handling.
set autoread                " Reread files changed outside of vim.
set noswapfile              " Do not create .swp files.
set backupdir=$XDG_DATA_HOME/vim/files/backup/
set backupext=-vimbackup
set backupskip=
set updatecount=100
set undofile
set undodir=$XDG_DATA_HOME/vim/files/undo/
set viminfo='100,n$XDG_DATA_HOME/vim/files/info/viminfo

" Misc
set gdefault                " Edits are global by default.

let mapleader = "\<Space>"
nnoremap <silent> <leader><leader> :source $MYVIMRC<cr>

" Very magic by default.
nnoremap ? ?\v
nnoremap / /\v
cnoremap %s/ %sm/

" Toggle line numbers.
nnoremap <F12> :set invrelativenumber<CR>:set invnu<CR>

" Toggle paste.
nnoremap <silent> <f5> :set paste!<cr>
inoremap <silent> <f5> <esc>:set paste!<cr>i

" Sudo make me a sandwich.
cmap w!! w !sudo tee > /dev/null %

" Show hidden chars.
nnoremap <leader>h :set invlist<cr>

" Insert mode for git commits.
au FileType gitcommit startinsert

" Keymap.
source ~/.config/nvim/keymap.vim
