function! yankitute#execute(cmd, start, end, reg) abort
  let [reg, cmd] = a:reg =~? '[a-z0-9"]' ? [a:reg, a:cmd] : ['"', a:reg . a:cmd]
  let sep = strlen(cmd) ? cmd[0] : '/'
	let [pat, s:replace, flags, join; _] = split(cmd[1:], '\v([^\\](\\\\)*\\)@<!%d' . char2nr(sep), 1) + ['', '', '', '']

  if pat != ''
    let @/ = pat
  endif

  if s:replace == ''
    let s:replace = '&'
  endif
  let is_sub_replace = s:replace =~ '^\\='
  let fn = 'yankitute#' . (is_sub_replace ? 'eval' : 'gather')

  let s:results = []
  let v:errmsg = ''
  try
    silent execute a:start . ',' . a:end . 's' . sep . pat . sep . '\=' . fn . '()' . sep . 'n' . flags
  catch
    let v:errmsg = substitute(v:exception, '.*:\zeE\d\+:\s', '', '')
    return 'echoerr v:errmsg'
  endtry

  let results = []
  if is_sub_replace
    let results = s:results
  else
    for m in s:results
      call add(results, substitute(s:replace, '\v%(%(\\\\)*\\)@<!%(\\(\d)|(\&))', '\=get(m,submatch(1)=="&"?0:submatch(1))', 'g'))
    endfor
  endif
  unlet s:results

  call setreg(reg, join == '' ? results : join(results, join))
  return ''
endfunction

function! yankitute#gather() abort
  let s:results += [map(range(10), 'submatch(v:val)')]
endfunction

function! yankitute#eval() abort
  call add(s:results, eval(s:replace[2:]))
endfunction
