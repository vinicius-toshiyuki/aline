" Create text property types
let g:aline#text = 0
let g:aline#long_text = 1

" Ids and information of formatted texts
" Entries are in the format (<aline_text text property id>, <info>)
let g:aline#properties = {}

" Return keys of properties in lnum and bufnr
function! aline#properties#get(...) abort
	let lnum = get(a:, 1, line('.'))
	let buffer = get(a:, 2, bufnr())

	let props = []
	for [key, value] in items(g:aline#properties)
		if (value.start <= lnum || value.end >= lnum) && value.bufnr == buffer
			call add(props, key)
		endif
	endfor

	return props
endfunction

function! aline#properties#add(id, start, end, sep, options) abort
	let buffer = get(a:options, 'bufnr', bufnr())
	if has_key(g:aline#properties, a:id)
		call aline#properties#remove(a:id)
	endif
	let l:type = a:end - a:start > g:aline#max_line_count ? g:aline#long_text : g:aline#text
	let g:aline#properties[a:id] = extend(#{start: a:start, end: a:end, sep: a:sep, type: l:type, bufnr: buffer}, a:options)
endfunction

function! aline#properties#remove(id) abort
	unlet g:aline#properties[a:id]
endfunction

" TODO
function! aline#properties#update(bufnr, start, end, added, changes) abort
	for chg in a:changes
		" Lines added
		if chg.added > 0
			" Get property affected
			let ids = aline#properties#get(chg.lnum, a:bufnr)
			" Increase property size
			if len(ids) && g:aline#properties[ids[0]].end < chg.end
				let g:aline#properties[ids[0]].end = chg.end
			endif
		" Lines removed
		elseif chg.added < 0
			" Get property affected
			let ids = aline#properties#get(chg.end - 1, a:bufnr)
			if len(ids)
				let last = chg.end - 1 - chg.added
				" If removed lines past the property end
				if last > g:aline#properties[ids[0]].end
					" End is line above first deleted line
					let g:aline#properties[ids[0]].end = chg.end - 2
				" Else removed lines inside property
				else
					" Decrease end by number of deleted lines
					let g:aline#properties[ids[0]].end += chg.added
				endif
				" If property is empty, remove it
				if g:aline#properties[ids[0]].end <= g:aline#properties[ids[0]].start
					call aline#properties#remove(ids[0])
				endif
			endif
		endif
	endfor
endfunction

