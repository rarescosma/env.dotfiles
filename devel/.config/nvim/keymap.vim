" Free up s and S (use cl instead of s and cc for S)
nmap s <Nop>
xmap s <Nop>
nmap S <Nop>

" Search results centered please.
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz

" Incremental change.
nnoremap cn *Ncgn

" Markdown link.
vnoremap <C-k> c[<C-r>"](<Esc>"+pa)<Esc>

" Quick templating
" 1) :let @t=@/ to copy the old search reg to a temp reg (so we don't clobber)
" 2) :let &ul=&ul to start a new change
" 3) search for '+>' and (ab)use visual mode to replace inside '<+ ... +>'
inoremap <C-t> <Esc>:let @t=@/<CR>:let &ul=&ul<CR>/\v\+\><CR>:nohl<CR>:let @/=@t<CR>lvF+;hc

" Insert mode shenanigans
" L -> end of line
" J -> out of )]}"'> (without clobbering the search reg)
" , -> paste during insert
inoremap <C-l> <C-o>$
inoremap <C-j> <Esc>:let @t=@/<CR>/[)}"'\]>]<CR>:<C-u>nohlsearch<CR>:let @/=@t<CR>a
inoremap <C-,> <C-r>"

" Search selection
vnoremap // "zy/\V<C-R>z<CR>

" Ctrl+B to stop searching.
nnoremap <C-b> :nohl<CR><C-l>
vnoremap <C-b> :nohl<CR><C-l>

" Ctrl+Q to quick-save and quit
" leader+w to quick-save
" Ctrl+z to suspend from insert
command! QS normal! :wq<CR>
map <C-q> <Esc>:QS<CR>
inoremap <C-q> <C-o>ZZ
nnoremap <leader>w :w<CR>
inoremap <C-z> <Esc><C-z>

" Register-preserving paste + delete.
xnoremap <silent> p p:let @"=@0<CR>
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
xnoremap < <gv
xnoremap > >gv
xnoremap <TAB> >gv
xnoremap <S-TAB> <gv
onoremap gv :<c-u>normal! gv<cr>

" Line beginning + end.
noremap L $
noremap H ^

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
