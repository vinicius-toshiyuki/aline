" TODO: Reformat blocks of formated text when changed -> Use text properties?
function! s:aline(sep) abort
	" Does nothing if the separator is not present in the current line
	if getline('.') !~ a:sep
		return 0
	endif

	" Save current view
	let l:view = winsaveview()

	" Get a regex-friendly separator
	let l:rsep = get({ '\': '\\', '^': '\^', '$': '\$', '.': '\.', '*': '\*', '~': '\~', '[': '\[', ']': '\]', '&': '\&'}, a:sep, a:sep)

	" Search for line boundaries
	let l:ls = search('^[^'.l:rsep.']*$', 'nbW') + 1
	let l:le = search('^[^'.l:rsep.']*$', 'nW') - 1
	if l:le <= 0 | let l:le = line('$') | endif

	" Get lines and split with the separator
	let l:lines = map(getline(l:ls, l:le), 'split(v:val, a:sep, 1)')

	" Get the column count
	let l:ccount = map(copy(l:lines), 'len(v:val)')->max()

	" Format lines
	for l:i in range(l:ccount)
		" Get the length of the l:i'th column
		let l:clen = map(copy(l:lines), 'len(v:val) > l:i ? strwidth(v:val[l:i]) : 0')->max()
		" Format the l:i'th column of each line
		for l:line in l:lines
			if len(l:line) > l:i && strwidth(l:line[l:i]) < l:clen
				let l:line[l:i] .= repeat(' ', l:clen - strwidth(l:line[l:i]))
			endif
		endfor
	endfor

	" Join columns of a line in a string
	let l:lines = map(l:lines, 'join(v:val, " '.a:sep.' ")')
	" Delete original text
	" TODO: Instead it should cut the text, format it and paste in place?
	execute 'silent! '.l:ls.','.l:le.'delete "_'
	" Append formated lines where the original were
	call append(l:ls - 1, l:lines)
	" Remove extra spaces in the end of the line (added to keep separators in
	" the end of the line)
	execute 'silent! '.l:ls.','.l:le.'substitute/\s\+$//'

	" Remove any added lines to the end of file
	if l:le + 1 == line('$')
		normal! G"_dd
	endif

	" Restore original view
	call winrestview(l:view)
	return 1
endfunction 
command! -bar -nargs=1 Aline :call s:aline(<f-args>)
