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
  let fn = 'yankitute#' . (is_sub_replace ? 'eval' : 'gather') . '()'

  if v:version >= 704 || (v:version == 703 && has('patch627'))
    let flags = 'n' .flags
  else
    let flags = substitute(flags, '\Cn', '', 'g')
  endif

  let s:results = []
  let v:errmsg = ''
  let win = winsaveview()
  try
    silent execute 'keepjumps ' . a:start . ',' . a:end . 's' . sep . pat . sep . '\=' . fn . sep . flags
  catch
    let v:errmsg = substitute(v:exception, '.*:\zeE\d\+:\s', '', '')
    return 'echoerr v:errmsg'
  finally
    if flags !~# 'n'
      call winrestview(win)
    endif
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

  let [join, type] = join == '' ? ["\n", 'l'] : [join, 'c']
  call setreg(reg, join(results, join), type)
  return ''
endfunction

function! yankitute#gather() abort
  let s:results += [map(range(10), 'submatch(v:val)')]
  return submatch(0)
endfunction

function! yankitute#eval() abort
  call add(s:results, eval(s:replace[2:]))
  rfunction! yankitute#execute(cmd, start, end, reg) abort,function,function! yankitute#gather() abort,function,function! yankitute#eval() abort,functioneturn submatch(0)
endfunction
