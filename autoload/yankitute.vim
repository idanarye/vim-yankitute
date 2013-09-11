
function! yankitute#yankWithPattern(cmd,fromLine,toLine,register)
	let l:separator=a:cmd[0]
	let l:cmdSplitted=split(a:cmd[1:],'\v([^\\](\\\\)*\\)@<!%d'.char2nr(l:separator),1)
	let l:pattern=l:cmdSplitted[0]
	let l:substitution=1<len(l:cmdSplitted) ? l:cmdSplitted[1] : ''

	let l:flags=2<len(l:cmdSplitted) ? l:cmdSplitted[2] : ''
	let l:allFlag=0<=stridx(l:flags,'g')

	let l:lines=getline(a:fromLine,a:toLine)
	let l:yankedStrings=[]
	for l:line in l:lines
		let l:matchFrom=0
		let l:match=matchstr(l:line,l:pattern)
		while(!empty(l:match) && (0==l:matchFrom || l:allFlag))
			let l:matchFrom=stridx(l:line,l:match,l:matchFrom)+max([len(l:match),1])
			if(!empty(l:substitution))
				call add(l:yankedStrings,substitute(l:match,l:pattern,l:substitution,''))
			else
				call add(l:yankedStrings,l:match)
			endif
			if(l:allFlag)
				let l:match=matchstr(l:line,l:pattern,l:matchFrom)
			endif
		endwhile
	endfor
	if(3<len(l:cmdSplitted))
		call setreg(a:register,join(l:yankedStrings,l:cmdSplitted[3]))
	else
		call setreg(a:register,join(l:yankedStrings,"\n").(empty(l:yankedStrings) ? '' : "\n"))
	endif
endfunction
