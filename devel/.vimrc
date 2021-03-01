" A minimal vimrc for new vim users to start with.
"
" Referenced here: http://vimuniversity.com/samples/your-first-vimrc-should-be-nearly-empty
"
" Original Author:       Bram Moolenaar <bram@vim.org>
" Made more minimal by:  Ben Orenstein
" Customized by:         Rares Cosma
"
let mapleader = "\<Space>"
nnoremap <silent> <leader><leader> :source $MYVIMRC<cr>

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
set nu
nmap <F12> :set invrelativenumber<CR>:set invnu<CR>
set ruler
set scrolloff=3

" Search
set ignorecase
set smartcase
set incsearch
set gdefault

" Search results centered please
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz

" Very magic by default
nnoremap ? ?\v
nnoremap / /\v
cnoremap %s/ %sm/

" Ctrl+n to stop searching
vnoremap <C-n> :nohlsearch<cr>
nnoremap <C-n> :nohlsearch<cr>

" Sudo make me a sandwich
set autoread
cmap w!! w !sudo tee > /dev/null %

" Quick-save
nmap <leader>w :w<CR>

" Moving lines up & down
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==

" Spacetab
set expandtab
set smarttab
set shiftwidth=4
set softtabstop=4
set tabstop=4

" Show those damn hidden characters
" Verbose: set listchars=nbsp:¬,eol:¶,extends:»,precedes:«,trail:•
set listchars=nbsp:¬,extends:»,precedes:«,trail:•,eol:¶
nnoremap <leader>h :set invlist<cr>

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines
