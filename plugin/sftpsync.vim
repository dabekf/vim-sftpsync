" ============================================================================
" File:        sftpsync.vim
" Description: Upload files to remote server via sftp
" Author:      Filip Dąbek <filedil@gmail.com>
" Website:     https://github.com/filedil
" License:     MIT License
" ============================================================================

if exists('g:sftpsync_loaded') || &compatible
    finish
elseif v:version < 800
    echohl Error
    echo "vim-sftpsync requires Vim 8+."
    echohl None
    finish
else
    let g:sftpsync_loaded = 1
endif

function! s:InitVar(var, value)
    if !exists(a:var)
        exec 'let '. a:var . '=' . string(a:value)
    endif
endfunction

call s:InitVar('g:sftpsync_host_keys_file', '')
call s:InitVar('g:sftpsync_private_key_file', '')
call s:InitVar('g:sftpsync_socket_timeout', 5)
call s:InitVar('g:sftpsync_cache_purge_timeout', 1800 * 1000) " every 30 minutes
call s:InitVar('g:sftpsync_print_time', 0)
call s:InitVar('g:sftpsync_use_statusline', 0)
call s:InitVar('g:sftpsync_projects', {})

