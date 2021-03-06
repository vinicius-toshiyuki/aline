" Select python3 function over vimscript only (if available)
let g:aline#use_python3 = get(g:, 'aline#use_python3', v:false)

" Text block maximum byte length to keep updating
" Negative values interpreted as unlimited
let g:aline#max_line_count = get(g:, 'aline#max_line_count', 100)

" Default separators padding
let g:aline#separator_padding = get(g:, 'aline#separator_padding', 0)

" Default text alignment
" '-': left, '+': right, '=': center
let g:aline#default_alignment = get(g:, 'aline#default_alignment', '-')

" File extensions to activate auto update formatting
let g:aline#update#file_types = get(g:, 'aline#update#file_types', [])

function! s:aline(range, line1, line2, sep, ...) abort
	" Get alignment
	let l:align_short = (substitute(get(a:, 1, ''), '[^-=+]', '', 'g').g:aline#default_alignment)[0]
	let l:align = get({'-': 'left', '+': 'right', '=': 'center'}, l:align_short, 'left')

	" Get separator padding
	let l:padding = (split(substitute(get(a:, 1, ''), '[^[:digit:]]', ' ', 'g')) + [g:aline#separator_padding])[0]
	if l:padding < 0 | let l:padding = g:aline#separator_padding | endif

	" Get clear extra spaces option
	let l:clear_extra = substitute(get(a:, 1, ''), '[^c]', '', 'g')[0]
	let l:clear_extra = l:clear_extra == 'c' ? v:true : v:false

	" Get keep start of line spaces option
	let l:keep_start = substitute(get(a:, 1, ''), '[^k]', '', 'g')[0]
	let l:keep_start = l:keep_start == 'k' ? v:true : v:false

	" Get no update option
	let l:noupdate = substitute(get(a:, 1, ''), '[^n]', '', 'g')[0]
	let l:noupdate = l:noupdate == 'n' ? v:true : v:false

	" Get a regex-friendly separator
	let l:rsep = escape(a:sep, '\^$.*~[]')

	" Does nothing if the separator is not present in the current line
	if getline('.') !~ l:rsep
		return 0
	endif

	" Search for line boundaries
	if a:range > 0
		let l:ls = a:line1
		let l:le = a:line2
		let l:noupdate = v:true
	else
		let l:ls = search('\(^.*'.l:rsep.'.*$\)\@<!$', 'nbW') + 1
		let l:le = search('\(^.*'.l:rsep.'.*$\)\@<!$', 'nW') - 1
		if l:le <= 0 | let l:le = line('$') | endif
	endif

	" Save current view
	let l:view = winsaveview()

	let l:Aline_engine = function(
				\ has('python3') && g:aline#use_python3 ?
				\ 's:python3' :
				\ 's:vim'
				\)
	" TODO: depois de alinhar colocar o cursor no lugar correto
	call l:Aline_engine(l:ls, l:le, a:sep, {'align': l:align, 'clear_extra': l:clear_extra, 'keep_start': l:keep_start, 'padding': l:padding})

	" Add property
	let l:prop = aline#properties#get(line('.'))
	let l:id = len(l:prop) > 0 ? l:prop[0] : len(g:aline#properties)
	call aline#properties#add(l:id, l:ls, l:le, a:sep, {'align': l:align_short, 'noupdate': l:noupdate})

	" Restore original view
	call winrestview(l:view)
	return 1
endfunction 
command! -range -bar -nargs=+ Aline :call <SID>aline(<range>, <line1>, <line2>, <f-args>)
command! -bar -nargs=0 AlineEnableUpdate :call aline#update#enable()
command! -bar -nargs=0 AlineDisableUpdate :call aline#update#disable()

call aline#update#setup()

function s:vim(ls, le, sep, options) abort
	" Get a regex-friendly separator
	let l:rsep = escape(a:sep, '\^$.*~[]')

	" Get lines and split with the separator
	let l:lines = map(
				\ getline(a:ls, a:le),
				\		'split(a:options.clear_extra ? substitute(v:val, '''.(
				\		a:options.keep_start ? '' : '^\s\+\|'
				\		).'\s*\('.l:rsep.'\)\s*\|\s\+$'', "\\1", "g") : v:val, l:rsep, 1)'
				\		)

	" Get column count
	let l:ccount = max(map(copy(l:lines), 'len(v:val)'))

	" Format lines
	for l:i in range(l:ccount)
		" Get length of the l:i'th column
		let l:clen = max(map(
					\ copy(l:lines),
					\ 'len(v:val) > l:i ?
					\ strdisplaywidth(
					\ 	substitute(
					\ 		v:val[l:i],
					\ 		"^\\s\\*\\([^\\s]*\\)\\s\\*$",
					\ 		"\\1", ""
					\ 	)
					\ ) : 0'))
		" Format l:i'th column of each line
		for l:line in l:lines
			if len(l:line) > l:i
				"let l:line[l:i] = substitute(substitute(l:line[l:i], '^\s\+', '', ""), '\s\+$', '', "")
				if strdisplaywidth(l:line[l:i]) < l:clen
					if a:options.align == 'left'
						let l:line[l:i] .= repeat(' ', l:clen - strdisplaywidth(l:line[l:i]))
					elseif a:options.align == 'right'
						let l:line[l:i] = repeat(' ', l:clen - strdisplaywidth(l:line[l:i])).l:line[l:i]
					elseif a:options.align == 'center'
						let l:lpad = l:clen - strdisplaywidth(l:line[l:i])
						let l:rpad = l:lpad / 2
						let l:lpad -= l:rpad
						let l:line[l:i] = repeat(' ', l:lpad).l:line[l:i].repeat(' ', l:rpad)
					endif
				endif
			endif
		endfor
	endfor

	" Join columns of a line in a string
	let l:lines = map(
				\ l:lines,
				\ 'join(v:val, "'.
				\ repeat(' ', a:options.padding).
				\ escape(a:sep, '\"').
				\ repeat(' ', a:options.padding).
				\ '")'
				\)
	" Replace lines with formatted lines
	call map(l:lines, 'setline('.a:ls.' + v:key, v:val)')
	" Remove extra spaces in the end of the line (added to keep separators in
	" the end of the line)
	execute 'silent! '.a:ls.','.a:le.'substitute/\s\+$//'
endfunction

function s:python3(ls, le, sep, options) abort
	execute 'py3 aline_start = '.a:ls.' - 1'
	execute 'py3 aline_end = '.a:le
	execute 'py3 aline_sep = "'.a:sep.'"'
	execute 'py3 aline_opt = vim.eval("'.string(a:options)->escape('"').'")'
py3 << END
import sys
import concurrent.futures
import datetime

def align(col):
	length = len(sorted(col, key=lambda k: len(k), reverse=True)[0])
	align_lambda = {
		'left' : lambda r: r.ljust(length),
		'right' : lambda r: r.rjust(length),
		'center' : lambda r: r.ljust(length // 2).rjust(length // 2 + length % 2)
	}
	col = map(align_lambda[aline_opt['align']], col)
	return list(col)


start = datetime.datetime.now()

lines = vim.current.buffer[aline_start:aline_end]
lines = list(map(lambda l: l.split(aline_sep), lines))
if aline_opt['clear_extra']:
	if not aline_opt['keep_start']:
		# strip() over a map of lines and words
		lines = list(map(lambda l: list(map(lambda w: w.strip(), l)), lines))
	else:
		lines = list(map(lambda l: [l[0].rstrip()] + list(map(lambda w: w.strip(), l[1:])), lines))

max_len = len(max(lines, key=lambda k: len(k)))
lines = list(map(lambda l: l + ([''] * (max_len - len(l))), lines))
columns = list(zip(*lines))

with concurrent.futures.ThreadPoolExecutor() as executor:
	threads = [executor.submit(align, col) for col in columns]

results = []
for th in threads:
	results.append(th.result())

padding = ' ' * aline_opt['padding']
results = list(map(lambda r: (padding + aline_sep + padding).join(r).rstrip(), zip(*results)))

end = datetime.datetime.now()

delta = end - start

print('Done in', delta.seconds + delta.microseconds / 10 ** 6)

vim.current.buffer[aline_start:aline_end] = results

END

endfunction

