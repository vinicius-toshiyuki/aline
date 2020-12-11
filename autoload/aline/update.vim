" Rerun Aline to format changed text
function! s:rerun() abort
	execute 'Aline '.escape(s:rerun_sep, ' ').'  0'.s:rerun_align
	unlet s:rerun_sep
	unlet s:rerun_align
endfunction

" Updates blocks
function! s:updateBlock() abort
	" Check if changes were made on a previously formatted text
	let ids = aline#properties#get()
	if len(ids) > 0
		let id = ids[0]
		let prop= g:aline#properties[id]
		if prop.type == g:aline#long_text || prop.noupdate | return | endif
		" Get right separator for this block
		let s:rerun_sep   = prop.sep
		let s:rerun_align = prop.align
		call s:rerun()
	endif
endfunction

function! aline#update#enable() abort
	augroup ALINE_UPDATE
		exec 'au CursorHold '.expand('%:p').' call <SID>updateBlock()'
		exec 'au CursorHoldI '.expand('%:p').' call <SID>updateBlock()'
	augroup END
endfunction

function! aline#update#disable() abort
	augroup ALINE_UPDATE
		exec 'au! CursorHold '.expand('%:p')
		exec 'au! CursorHoldI '.expand('%:p')
	augroup END
endfunction

function aline#update#setup() abort
	for ft in g:aline#update#file_types
		exec 'au ALINE_UPDATE FileType '.ft.' call aline#update#enable()'
	endfor
endfunction
