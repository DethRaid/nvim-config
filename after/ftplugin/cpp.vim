set commentstring=//\ %s

" Disable inserting comment leader after hitting o or O or <Enter>
set formatoptions-=o
set formatoptions-=r

function! s:compile_run_cpp() abort
  let src_path = expand('%:p:~')
  let src_noext = expand('%:p:~:r')

  call s:create_term_buf('h', 20)
  execute printf('term ./build.py -c=debug')
  startinsert
endfunction

function s:create_term_buf(_type, size) abort
  set splitbelow
  set splitright
  if a:_type ==# 'v'
    vnew
  else
    new
  endif
  execute 'resize ' . a:size
endfunction

nnoremap <silent> <buffer> <c-b> :call <SID>compile_run_cpp()<CR>

