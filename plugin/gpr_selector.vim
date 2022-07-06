if exists('g:loaded_gpr_selector') | finish | endif " prevent loading file twice

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to defaults

function! s:GPRSelect(filename=v:null) abort
  if a:filename !=# v:null
    let l:filename = resolve(a:filename)
  else
    let l:filename = v:null
  endif
  call luaeval("require'gpr_selector'.gpr_select_manual(_A[1])", [l:filename])
endfunction

command! -nargs=? -complete=file GPRSelect call s:GPRSelect(<f-args>)

let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

let g:loaded_gpr_selector = 1
