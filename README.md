# vim-sftpsync
Upload files to remote server via sftp in Vim.

This plugin allows you to send a file from a local project to a remote server using SFTP protocol. Unlike other plugins I've looked at, this one doesn't start external processes, but uses the Vim's python interface and python SSH library, [Paramiko](http://www.paramiko.org/). That way start times are shorter and you can reuse open connections, so subsequent uploads are even faster (I've measured 0.1s and lower). Makes it great for hooking to an autocommand like `BufWritePost`.

Requirements
------------
- Vim 8 or higher with +python3 and +timers (Python 2 support might be added later)
- Python 3 with Paramiko library installed

Installation
------------
If you use [vim-plug](https://github.com/junegunn/vim-plug), then add the following line to your vimrc file:

```vim
Plug 'filedil/vim-sftpsync'
```

and then use `:PlugInstall`. Or, you can use any other plugin manager such as
[vundle](https://github.com/gmarik/vundle),
[dein](https://github.com/Shougo/dein.vim),
[neobundle](https://github.com/Shougo/neobundle.vim), or
[pathogen](https://github.com/tpope/vim-pathogen).

Basic configuration
-------------------
There are two important variables:

* `g:sftpsync_private_key_file` - point this to your ssh identity (private key) if you don't want to keep passwords in configuration

    Example:
    ```vim
    let g:sftpsync_private_key_file = 'C:/Cygwin64/home/$USERNAME/.ssh/id_rsa'
    ```


* `g:sftpsync_projects` - where to send which files

    This is a list of "projects" that will match a source pattern (e.g. a local directory) to one or more destinations.

    Example:
    ```vim
    let g:sftpsync_projects = {
    \    'myproject': {
    \        'source': '^.+/Projects/(Work/)?([a-z0-9]+)_myproject',
    \        'destination': {
    \            'dev': {
    \                'directory': '/home/www/\2_myproject',
    \                'hosts': ['user@giraffe.example.com'],
    \            },
    \            'test': {
    \                'directory': '/home/www/myproject',
    \                'hosts': ['user@hippo.example.com', 'user:p4ssw0rd@lion.example.com'],
    \            },
    \        }
    \    },
    \}
    ```

    This configuration will tell the plugin to:
    - send any file from `*/Projects/test1_myproject` to `/home/www/test1_myproject` on `giraffe.example.com`,

        if the chosen target is 'dev'
    - send any file from `*/Projects/Work/test2_myproject` to `/home/www/test2_myproject` on `giraffe.example.com`,

        if the chosen target is 'dev'
    - send any file from `*/Projects/test1_myproject` to `/home/www/myproject` on both `hippo` and `lion` servers,

        if the chosen target is 'test'
    - etc.

Basic usage
-----------
```vim
:call sftpsync#Upload([filename], [target])
```

Arguments:
* `filename` - full path to the uploaded file
* `target` - alias of the target server(s), from `g:sftpsync_projects`

If `target` is not set, variable `b:sftpsync_target` might be used, if it exists.

If `filename` is also not set, `expand('%:p')` will be used instead (path to currently open buffer).

Shortcut and autocommand examples
--------------------
```vim
nnoremap <silent> <F12> :call sftpsync#Upload(expand('%:p'), 'test')<CR>
nnoremap <silent> <F11> :call sftpsync#Cycle(['test', '', 'other_test'])<CR>

augroup sftpsync
    autocmd!
    autocmd BufNewFile,BufRead ~/Projects/* call sftpsync#Init('test', 1)
    autocmd BufWritePost ~/Projects/* call sftpsync#Upload()
augroup END
```

Other
-----
There are few more configuration variables, functions and some statusline support. Please consult project's .vim files.

License
-------
vim-sftpsync is licensed under the *MIT License*.

