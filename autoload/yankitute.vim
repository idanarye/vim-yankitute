function! yankitute#execute(cmd, start, end, reg) abort
    let [l:reg, l:cmd] = a:reg =~? '[a-z0-9"]' ? [a:reg, a:cmd] : ['"', a:reg . a:cmd]
    let l:sep = strlen(l:cmd) ? l:cmd[0] : '/'
    let [l:pat, l:replace, l:flags, l:join; _] = split(l:cmd[1:], '\v([^\\](\\\\)*\\)@<!%d' . char2nr(l:sep), 1) + ['', '', '', '']

    if l:pat != ''
        let @/ = l:pat
    endif

    if l:replace == ''
        let l:replace = '&'
    endif
    let l:is_sub_replace = l:replace =~ '^\\='
    if l:is_sub_replace
        let l:fn = 's:eval(l:results, l:replace)'
    else
        let l:fn = 's:gather(l:results)'
    endif

    if l:flags =~ '\Cn'
        return 'echoerr "the n flag is not allowed in Yankitute"'
    elseif l:flags =~ '\Cc'
        return 'echoerr "the c flag is not allowed in Yankitute"'
    endif
    let l:flags = substitute(l:flags, '\Cn', '', 'g')

    let l:results = []
    let v:errmsg = ''
    let l:winview = winsaveview()
    let l:winrestcmd = winrestcmd()
    let l:winfixwidths = map(range(1, winnr('$')), 'getwinvar(v:val, "&winfixwidth")')
    let l:winfixheights = map(range(1, winnr('$')), 'getwinvar(v:val, "&winfixwidth")')
    windo setlocal winfixwidth
    windo setlocal winfixheight
    try
        let l:bufnr = bufnr('')
        new
        try
            setlocal buftype=nofile
            setlocal bufhidden=wipe
            call setline(1, getbufline(l:bufnr, 0, '$'))
            silent execute 'keepjumps ' . a:start . ',' . a:end . 'substitute' . l:sep . l:pat . l:sep . '\=' . l:fn . l:sep . l:flags
        finally
            bdelete!
        endtry
    catch
        let v:errmsg = substitute(v:exception, '.*:\zeE\d\+:\s', '', '')
        return 'echoerr v:errmsg'
    finally
        for l:i in range(1, winnr('$'))
            call setwinvar(l:i, '&winfixwidth', l:winfixheights[l:i - 1])
            call setwinvar(l:i, '&winfixheight', l:winfixheights[l:i - 1])
        endfor
        execute l:winrestcmd
        call winrestview(l:winview)
    endtry

    if !l:is_sub_replace
        for l:i in range(len(l:results))
            let l:results[l:i] = substitute(l:replace, '\v%(%(\\\\)*\\)@<!%(\\(\d)|(\&))', '\=get(l:results[l:i],submatch(1)=="&"?0:submatch(1))', 'g')
        endfor
    endif

    let [l:join, type] = l:join == '' ? ["\n", 'l'] : [l:join, 'c']
    call setreg(l:reg, join(l:results, l:join), type)
    return ''
endfunction

function! s:gather(results) abort
    call add(a:results, map(range(10), 'submatch(v:val)'))
    return submatch(0)
endfunction

function! s:eval(results, replace) abort
    call add(a:results, eval(a:replace[2:]))
    return submatch(0)
endfunction
