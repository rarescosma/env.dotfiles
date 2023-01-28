" Free up s and S (use cl instead of s and cc for S)
nmap s <Nop>
xmap s <Nop>
nmap S <Nop>

" Argument insert/append
nmap si viaovi <C-h>,<C-h>
nmap sa viava,<space>

" Search results centered please.
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz

" Incremental change.
nnoremap cn *Ncgn

" Ctrl+B to stop searching.
nnoremap <C-b> :nohl<CR><C-l>
vnoremap <C-b> :nohl<CR><C-l>

" Quick-save (and quit).
nnoremap <leader>w :w<CR>
inoremap <C-z> <C-o>ZZ

" Register-preserving paste + delete.
xnoremap <leader>p "_dP
nnoremap <leader>d "_d
vnoremap <leader>d "_d

" Clobbering yanks.
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>Y mzgg"+yG`z

" Move lines up & down.
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==

" Indents.
nnoremap > >>
nnoremap < <<
xnoremap <  <gv
xnoremap >  >gv
xnoremap <TAB> >gv
xnoremap <S-TAB> <gv
onoremap gv  :<c-u>normal! gv<cr>

" Line beginning + end.
noremap L $
noremap H ^

" Move during insert.
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>

" Center block nav please.
nnoremap }   }zz
nnoremap {   {zz
nnoremap ]]  ]]zz
nnoremap [[  [[zz
nnoremap []  []zz
nnoremap ][  ][zz
