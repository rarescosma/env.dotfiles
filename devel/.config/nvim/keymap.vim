" Search results centered please.
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz

" Ctrl+l to stop searching.
nnoremap <C-l> :nohl<CR><C-l>
vnoremap <C-l> :nohl<CR><C-l>

" Quick-save.
nmap <leader>w :w<CR>

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
noremap \ ;

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

" Swap mark jump modes.
nnoremap '  `
nnoremap `  '
