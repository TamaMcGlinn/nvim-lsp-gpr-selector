function! gpr_selector#Select(filename=v:null) abort
  if a:filename !=# v:null
    let l:filename = resolve(a:filename)
  else
    let l:filename = v:null
  endif
  call luaeval("require'gpr_selector'.gpr_select_manual(_A[1])", [l:filename])
endfunction

function! gpr_selector#SelectFuzzy() abort
  call fzf#vim#files('', fzf#vim#with_preview({'source': 'git ls-files | grep "\.gpr$"', 'sink': function('gpr_selector#Select')}))
endfunction

