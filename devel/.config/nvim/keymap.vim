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

" Quick-save.
nnoremap <leader>w :w<CR>

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

" Visual block with <Alt+V>.
nnoremap <M-v> <c-v>

" Visual, visual.
xnoremap <  <gv
xnoremap >  >gv
onoremap gv  :<c-u>normal! gv<cr>

" Line beginning + end.
nnoremap L $
vnoremap L $
nnoremap H ^
vnoremap H ^

" Quicker commands.
noremap ; :
noremap : ;

" Move during insert.
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
inoremap <C-o> <ESC>o

" Center block nav please.
nnoremap }   }zz
nnoremap {   {zz
nnoremap ]]  ]]zz
nnoremap [[  [[zz
nnoremap []  []zz
nnoremap ][  ][zz
