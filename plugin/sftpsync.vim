" ============================================================================
" File:        sftpsync.vim
" Description: Upload files to remote server via sftp
" Author:      Filip Dąbek <filedil@gmail.com>
" Website:     https://github.com/filedil
" License:     MIT License
" ============================================================================

function! s:InitVar(var, value)
	if !exists(a:var)
		exec 'let '. a:var . '=' . string(a:value)
	endif
endfunction

call s:InitVar('g:sftpsync_host_keys_file', '')
call s:InitVar('g:sftpsync_private_key_file', '')
call s:InitVar('g:sftpsync_socket_timeout', 3)
call s:InitVar('g:sftpsync_cache_purge_timeout', 900 * 1000) " every 15 minutes
call s:InitVar('g:sftpsync_print_time', 0)
call s:InitVar('g:sftpsync_use_statusline', 0)
call s:InitVar('g:sftpsync_projects', {})

