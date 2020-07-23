" Ids and separators of formatted texts
" Entries are in the format (<aline_text text property id>, <separator>)
let s:prop_ids = {}

function! s:aline(range, line1, line2, sep, ...) abort
	" Get alignment
	let l:align = get({0: 'left', '+': 'right', '=': 'center'}, get(a:, 1))

	" Get a regex-friendly separator
	let l:rsep = escape(a:sep, '\^$.*~[]')

	" Does nothing if the separator is not present in the current line
	if getline('.') !~ l:rsep
		return 0
	endif

	" Save current view
	let l:view = winsaveview()

	" Search for line boundaries
	if a:range > 0
		let l:ls = a:line1
		let l:le = a:line2
	else
		let l:ls = search('\(^.*'.l:rsep.'.*$\)\@<!$', 'nbW') + 1
		let l:le = search('\(^.*'.l:rsep.'.*$\)\@<!$', 'nW') - 1
		if l:le <= 0 | let l:le = line('$') | endif
	endif

	" Get lines and split with the separator
	let l:lines = map(getline(l:ls, l:le), 'split(v:val, l:rsep, 1)')

	" Get the column count
	let l:ccount = map(copy(l:lines), 'len(v:val)')->max()

	" Format lines
	for l:i in range(l:ccount)
		" Get the length of the l:i'th column
		let l:clen = map(copy(l:lines), 'len(v:val) > l:i ? strdisplaywidth(v:val[l:i]) : 0')->max()
		" Format the l:i'th column of each line
		for l:line in l:lines
			if len(l:line) > l:i
				let l:line[l:i] = substitute(substitute(l:line[l:i], '^\s\+', '', ""), '\s\+$', '', "")
				if strdisplaywidth(l:line[l:i]) < l:clen
					if l:align == 'left'
						let l:line[l:i] .= repeat(' ', l:clen - strdisplaywidth(l:line[l:i]))
					elseif l:align == 'right'
						let l:line[l:i] = repeat(' ', l:clen - strdisplaywidth(l:line[l:i])).l:line[l:i]
					elseif l:align == 'center'
						let l:lpad = l:clen - strdisplaywidth(l:line[l:i])
						let l:rpad = l:lpad / 2
						let l:lpad -= l:rpad
						let l:line[l:i] = repeat(' ', l:lpad).l:line[l:i].repeat(' ', l:rpad)
					endif
				endif
			endif
		endfor
	endfor

	" Get past property
	let l:prop = prop_list(l:ls, {'type': 'aline_text'})

	" Join columns of a line in a string
	let l:lines = map(l:lines, 'join(v:val, "'.escape(a:sep, '\').'")')
	" Replace lines with formatted lines
	call setreg('"=', l:lines)
	execute 'silent! normal! '.l:ls.'GV'.l:le.'Gp'
	" Remove extra spaces in the end of the line (added to keep separators in
	" the end of the line)
	execute 'silent! '.l:ls.','.l:le.'substitute/\s\+$//'

	" Add property
	let l:id = len(l:prop) > 0 ? l:prop[0]['id'] : len(s:prop_ids)
	call prop_add(
		\ l:ls,
		\ 1,
		\ {
		\ 'id': l:id,
		\ 'end_lnum': l:le,
		\ 'end_col': strlen(getline(l:le)),
		\ 'type': 'aline_text'
		\ })
	let s:prop_ids[l:id] = {'sep': a:sep, 'align': get(a:, 1)}

	" Restore original view
	call winrestview(l:view)
	return 1
endfunction 
command! -range -bar -nargs=+ Aline :call s:aline(<range>, <line1>, <line2>, <f-args>)

" Text property to keep track of previously formatted text
if prop_type_list()->index('aline_text') < 0
	call prop_type_add('aline_text', {'start_incl': 1, 'end_incl': 1, 'combine': 1})
endif

" Time to not update the alignment after an update
let g:aline_hold_time = 500
" Time with no new changes needed to update the alignment
let g:aline_update_time = 750

" Control the access to the update function 
" Updates are paused for 'g:aline_hold_time' ms
let s:alinable = 1
function! s:alinableControl(id) abort
	let s:alinable = 1
endfunction
let s:alinable_control_handler = function('s:alinableControl')

" Rerun Aline to format changed text
function! s:rerun(id) abort
	execute 'Aline '.s:rerun_sep.'  '.s:rerun_align
	let s:alinable = 0
	unlet s:rerun_sep
	unlet s:rerun_align
	" Set up a timer to re-enable updating
	call timer_start(g:aline_hold_time, s:alinable_control_handler)
endfunction
let s:rerun_handler = function('s:rerun')

" Id of the timer that waits for an idle state to update
let s:timer_id = 0
" Callback to changed text that decides whether or not it is needed to update
function! s:updateBlock(bufnr, start, end, added, changes) abort
	" Exits if it is not insert mode or updating is paused
	if mode() != 'i' || !s:alinable | return 0 | endif
	" Check if the changes were made on an previously formatted text
	let l:prop = prop_list(line('.'), {'bufnr': a:bufnr, 'type': 'aline_text'})
	for l:p in l:prop
		" Get the right separator for this block
		let s:rerun_sep   = s:prop_ids[l:p['id']]['sep']
		let s:rerun_align = s:prop_ids[l:p['id']]['align']
		" Reset the timer waiting for an idle state
		call timer_stop(s:timer_id)
		let s:timer_id = timer_start(g:aline_update_time, s:rerun_handler)
	endfor
	return 1
endfunction
let s:update_handler = function('s:updateBlock')

augroup aline
	" Add listener to changes to keep alignment updated
	autocmd! BufEnter teste let s:listener_id = listener_add(s:update_handler, buffer_name())
augroup end

