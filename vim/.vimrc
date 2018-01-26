" A minimal vimrc for new vim users to start with.
"
" Referenced here: http://vimuniversity.com/samples/your-first-vimrc-should-be-nearly-empty
"
" Original Author:       Bram Moolenaar <bram@vim.org>
" Made more minimal by:  Ben Orenstein
" Customized by:         Rares Cosma
"

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" Do not create .swp files
set noswapfile

" Make backspace behave in a sane manner.
set backspace=indent,eol,start

" Switch syntax highlighting on
syntax on

" Enable file type detection and do language-dependent indenting.
filetype plugin indent on
set paste

" Type
set background=dark
set t_Co=8 t_md=

" Navigation
set relativenumber
nmap <F12> :set invrelativenumber<CR>
set ruler
set scrolloff=3

" Search
set ignorecase
set smartcase
set incsearch
set hlsearch

" Tee trick
set autoread
cmap w!! w !sudo tee > /dev/null %

