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

" Markdown link.
vnoremap <C-k> c[<C-r>"](<Esc>"*pa)<Esc>

" Quick templating
" 1) :let @t=@/ to copy the old search reg to a temp reg (so we don't clobber)
" 2) :let &ul=&ul to start a new change
" 3) search for '+>' and (ab)use visual mode to replace inside '<+ ... +>'
inoremap <C-t> <Esc>:let @t=@/<CR>:let &ul=&ul<CR>/\v\+\><CR>:nohl<CR>:let @/=@t<CR>lvF+;hc

" Ctrl+B to stop searching.
nnoremap <C-b> :nohl<CR><C-l>
vnoremap <C-b> :nohl<CR><C-l>

" Quick-save (and quit).
command! QS normal! :wq<CR>
map <C-q> <Esc>:QS<CR>
inoremap <C-q> <C-o>ZZ
nnoremap <leader>w :w<CR>
inoremap <C-z> <Esc><C-z>

" Register-preserving paste + delete.
xnoremap <leader>p "_dP
nnoremap <leader>d "_d
vnoremap <leader>d "_d

" Clobbering yanks.
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>Y mzgg"+yG`z

" Select most recently modified text
nnoremap gV `[v`]

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

" Visual block.
command! VB normal! <C-v>
nnoremap <A-v> :VB<CR>
vnoremap <A-v> <Esc>
