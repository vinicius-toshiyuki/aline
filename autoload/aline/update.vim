" Time to not update the alignment after an update
let g:aline#update#hold_time = 500
" Time with no new changes needed to update the alignment
let g:aline#update#update_time = 750
" File extensions to activate auto update formatting
let g:aline#update#file_types = []

" Control the access to the update function 
" Updates are paused for 'g:aline#hold_time' ms
let s:alinable = 1
function! s:alinableControl(id) abort
	let s:alinable = 1
endfunction
let s:alinable_control_handler = function('s:alinableControl')

" Rerun Aline to format changed text
function! s:rerun(id) abort
	execute 'Aline '.escape(s:rerun_sep, ' ').'  0'.s:rerun_align
	let s:alinable = 0
	unlet s:rerun_sep
	unlet s:rerun_align
	" Set up a timer to re-enable updating
	call timer_start(g:aline#update#hold_time, s:alinable_control_handler)
endfunction
let s:rerun_handler = function('s:rerun')

" Id of the timer that waits for an idle state to update
let s:timer_id = 0
" Callback to changed text that decides whether or not it is needed to update
function! s:updateBlock(bufnr, start, end, added, changes) abort
	" Exits if it is not insert mode or updating is paused
	if mode() != 'i' || !s:alinable | return 0 | endif
	" Check if the changes were made on an previously formatted text
	let l:prop = aline#properties#get()
	for l:p in l:prop
		let l:prop_data = g:aline#properties[l:p.id]
		if l:p.type == 'aline_long_text' | return 0 | endif
		" Get the right separator for this block
		let s:rerun_sep   = l:prop_data.sep
		let s:rerun_align = l:prop_data.align
		" Reset the timer waiting for an idle state
		call timer_stop(s:timer_id)
		let s:timer_id = timer_start(g:aline#update#update_time, s:rerun_handler)
	endfor
	return 1
endfunction
let s:update_handler = function('s:updateBlock')

let s:listener_id = {}
function! s:enableUpdate() abort
	let s:listener_id[buffer_name()] = listener_add(s:update_handler, buffer_name())
endfunction
command! AlineEnableUpdate :call <SID>enableUpdate()

function! s:disableUpdate() abort
	call listener_remove(s:listener_id[buffer_name()])
	unlet s:listener_id[buffer_name()]
endfunction
command! AlineDisableUpdate :call <SID>disableUpdate()

augroup aline
	" Add listener to changes to keep alignment updated
	for l:ft in g:aline#update#file_types
		execute 'autocmd! BufEnter *.'.l:ft.' let s:listener_id[buffer_name()] = listener_add(s:update_handler, buffer_name())'
	endfor
augroup end
