if exists('g:loaded_gpr_selector') | finish | endif " prevent loading file twice

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to defaults

command! GPRSelect lua require'gpr_selector'.gpr_select_manual()

let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

let g:loaded_gpr_selector = 1
