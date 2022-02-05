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

" Spacetab
set autoindent              " Indent according to previous line.
set expandtab               " Use spaces instead of tabs.
set smarttab
set softtabstop=2           " Tab key indents by 4 spaces.
set shiftwidth=2            " >> indents by 4 spaces.
set shiftround              " >> indents to next multiple of 'shiftwidth'.
set smartindent             " Smart indent.

set backspace=indent,eol,start " Make backspace behave in a sane manner.
set hidden                  " Switch between buffers without having to save first.

" Display
set laststatus=2            " Always show statusline.
set display=lastline        " Show as much as possible of the last line.
set showmode                " Show current mode in command-line.
set showcmd                 " Show already typed keys when more are expected.
set lazyredraw              " Only redraw when necessary.
set cursorline              " Find the current line quickly.
set report=0                " Always report changed lines.
set synmaxcol=200           " Only highlight the first 200 columns.
set relativenumber          " Relative line numbers.
set nu                      " Display line numbers.
set listchars=nbsp:¬,extends:»,precedes:«,trail:•,eol:¶   " Show those damn hidden characters
set scrolloff=3             " Display a couple of lines of context.
set nolinebreak

" Search
set incsearch               " Highlight searches.
set ignorecase              " Ignore case by default.
set smartcase               " But make it count if sarch contains UPPERs.

" File handling
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

" Keymap
let mapleader = "\<Space>"
nnoremap <silent> <leader><leader> :source $MYVIMRC<cr>

" Very magic by default.
nnoremap ? ?\v
nnoremap / /\v
cnoremap %s/ %sm/

" Toggle line numbers.
nmap <F12> :set invrelativenumber<CR>:set invnu<CR>

" Toggle paste.
set pastetoggle=<F5>

" Sudo make me a sandwich.
cmap w!! w !sudo tee > /dev/null %

" Show hidden chars.
nnoremap <leader>h :set invlist<cr>

" Insert mode for git commits.
au FileType gitcommit startinsert

" Keymap.
source ~/.config/nvim/keymap.vim
