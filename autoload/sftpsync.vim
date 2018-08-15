" ============================================================================
" File:        sftpsync.vim
" Description: Upload files to remote server via sftp
" Author:      Filip Dąbek <filedil@gmail.com>
" Website:     https://github.com/filedil
" License:     MIT License
" ============================================================================

if !has('python3') || !has('timers')
	echohl Error
	echo "Error: vim-sftpsync requires vim compiled with +python3 and +timers"
	echohl None
	finish
endif

exec "py3 import vim, sys, os.path"
exec "py3 cwd = vim.eval('expand(\"<sfile>:p:h\")')"
exec "py3 sys.path.insert(0, os.path.join(cwd, 'sftpsync', 'python'))"

exec "py3 from sftpsync import *"

function! sftpsync#PurgeConnections(timer)
	" Purge connection cache regularly to prevent freezes
	execute "py3 sftpSync.purgeCache()"
endfunction

function! sftpsync#Upload(...)
	if exists('a:1') && a:1 != ""
		let filename = a:1
	else
		let filename = expand("%:p")
	endif

	if exists('a:2') && a:2 != ""
		let target = a:2
	elseif exists('b:sftpsync_target')
		let target = b:sftpsync_target
	else
		let target = ""
	endif

	if filename == "" || target == ""
		return
	endif

	if !&shellslash
		let filename = fnamemodify(filename, ':gs@\\@/@')
	endif

	let b:sftpsync_status = "running"
	if g:sftpsync_use_statusline == 1
		redraws
	endif

	if g:sftpsync_print_time == 1
		let start_time = reltimefloat(reltime())
	endif

	execute "py3 sftpSync.upload('" . filename . "', '" . target . "')"

	if b:sftpsync_status == "done"
		if g:sftpsync_use_statusline == 1
			redraws
		endif
		if g:sftpsync_print_time == 1
			echo printf('Upload time: %f', reltimefloat(reltime()) - start_time)
		endif
	endif
endfunction

function! sftpsync#Init(target, once)
	if exists('b:sftpsync_target') && a:once
		return
	endif

	let b:sftpsync_target = a:target
	let b:sftpsync_status = 'ready'
endfunction

function! sftpsync#Cycle(targets)
	if !exists('b:sftpsync_target')
		call sftpsync#Init(a:targets[0], 0)
		return
	endif

	let index = index(a:targets, b:sftpsync_target)

	if index == -1
		return
	endif

	try
		call sftpsync#Init(a:targets[index + 1], 0)
	catch
		call sftpsync#Init(a:targets[0], 0)
	endtry
endfunction
