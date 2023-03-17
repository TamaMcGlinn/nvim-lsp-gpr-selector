if exists('g:loaded_gpr_selector') | finish | endif " prevent loading file twice

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to defaults

command! -nargs=? -complete=file GPRSelect call gpr_selector#Select(<f-args>)
command! GPRSelectFuzzy call gpr_selector#SelectFuzzy()

let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

let g:loaded_gpr_selector = 1
