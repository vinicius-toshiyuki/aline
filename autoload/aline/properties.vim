" Create text property types
if !len(prop_type_get('aline_text'))
	call prop_type_add('aline_text', {})
endif

if !len(prop_type_get('aline_long_text'))
	call prop_type_add('aline_long_text', {})
endif

" Ids and information of formatted texts
" Entries are in the format (<aline_text text property id>, <info>)
let g:aline#properties = {}

function! aline#properties#get(...) abort
	let lnum = get(a:, 1, line('.'))
	let bufnr = get(a:, 2, bufnr())
	return prop_list(lnum, {'bufnr': bufnr, 'type': 'aline_text'})
endfunction

function! aline#properties#add(id, start, end, sep, options) abort
	if has_key(g:aline#properties, a:id)
		call aline#properties#remove(a:id)
	endif
	let l:type = a:end - a:start > g:aline#max_line_count ? 'aline_long_text' : 'aline_text'
	call prop_add(a:start, 1, #{end_lnum: a:end, end_col: len(getline(a:end)), id: a:id, type: l:type})
	let g:aline#properties[a:id] = extend(#{start: a:start, end: a:end, sep: a:sep}, a:options)
endfunction

function! aline#properties#remove(id) abort
	call prop_remove(#{id: a:id})
	unlet g:aline#properties[a:id]
endfunction

