scriptencoding utf-8
source ~/.config/nvim/plugins.vim

" Enables lexical hihlighting
syntax on

" Enables filetype detection, loads the file's plugin and syntax
filetype plugin indent on

" So that :vsplit opens a file on the right
set splitright
" Highlight the current line
set cursorline

" Don't show last command
set noshowcmd

" Yank and paste with the system clipboard
set clipboard+=unnamedplus

" Hides buffers instead of closing them
set hidden

" Insert spaces when TAB is pressed.
set expandtab

" Change number of spaces that a <Tab> counts for during editing ops
set softtabstop=2

" Indentation amount for < and > commands.
set shiftwidth=2

" Disable line/column number in status line
" Shows up in preview window when lightline is disabled if not
set noruler

" Only one line for command line
set cmdheight=1

" partial command is displayed on the bottom right (normal & visual mode)
set showcmd

" Don't give completion messages like 'match 1 of 2'
" r 'The only match'
set shortmess+=c

" Remap leader key to ,
let g:mapleader=','

let s:colors = onedark#GetColors()

" Enable true color support
set termguicolors
" Editor theme
" colorscheme solarized8
" colorscheme apprentice
set background=light
" colorscheme plastic
" colorscheme flattened_dark
" colorscheme nord
" let g:nord_underline = 1
" colorscheme spring-night
colorscheme onedark





" This is to highlight lines > 80 chars
" match Error /\%81v.\+/
" highlight link OverLength Error
" highlight link ExtraWhitespace Error

" augroup additional_matches
"
"     autocmd!
"     autocmd BufEnter,WinEnter * call matchadd('OverLength', '\%>80v.\+', -1)
"     autocmd BufEnter,WinEnter * call matchadd('ExtraWhitespace', '\s\+\%#\@<!$/', -1)
" augroup END

" remove whitespace
autocmd BufWritePre * %s/\s\+$//e

" Change vertical split character to be a space (essentially hide it)
" set fillchars+=vert:|

" Set preview window to appear at bottom
set splitbelow

" Don't dispay mode in command line (airilne already shows it)
set noshowmode

nnoremap Y y$


" takes you to ex mode to replace the word under the cursor
nnoremap <leader>se :%s/\<<C-R><C-W>\>

" Load vimrc
nnoremap <leader>fed :e $MYVIMRC<CR>
" Reload the configuration
nnoremap <leader>feR :source $MYVIMRC<CR>
" Save file, (update so that the file is modified only if it is changed)
nnoremap <leader>fs :update<CR>
nnoremap <leader>fw :w <C-R>=expand("%:p:h") . "/" <CR>


" Open the current file in dirvish
nmap <leader>, <Plug>(dirvish_up)

augroup dirvish_config
  autocmd!
  autocmd FileType dirvish
    \ nnoremap <expr> <buffer> r ":!mv ".shellescape(getline('.'))." ".shellescape(getline('.'))."<Left>"
    \ |nnoremap <expr> <buffer> + ":!mkdir -p ".shellescape(expand('%'))."<Left>"

augroup END

" bd deletes the entire buffer, we only want to
" drop the current window
nnoremap <leader>bd :hide<CR>

" maximize the current buffer
nnoremap <silent> <leader>wm :only<CR>
nnoremap <silent> <leader>w2 <cmd>lua require('window').SetWindowsN(2)<CR>
nnoremap <silent> <leader>w3 <cmd>lua require('window').SetWindowsN(3)<CR>
nnoremap <silent> <leader>wl <C-W>l
nnoremap <silent> <leader>wh <C-W>h
nnoremap <silent> <leader>w= <C-W>=
nnoremap <silent> <leader>ww <C-W><C-W>

nnoremap <silent> <leader>tt q:
nnoremap <silent> <leader>ts q/

xmap <leader>cl <Plug>Commentary
nmap <leader>cl <Plug>CommentaryLine
" copy the current line, move up, comment it out, come down
nnoremap <leader>cc :t.-1<CR>:Commentary<CR>j
" :t.-1<CR> - copies the current selection, above the current line
" gc`.      - copies till the lat edit
" ``        - jump back to the last jump
" j         - go down one line
" TODO: this is buggy
xmap <leader>cc :t.-1<CR>gc`.``j

function! FindGitRoot()
  let current_file_directory = expand('%:p:h')
  let maybe_git_root = system(join(['git -C', current_file_directory, 'rev-parse --show-toplevel 2> /dev/null'], ' '))[:-2]
  if maybe_git_root == ""
    return current_file_directory
  else
    return maybe_git_root
  endif
endfunction

sign define LspDiagnosticsSignError text=> texthl=LspDiagnosticsDefaultError linehl= numhl=
sign define LspDiagnosticsSignWarning text=> texthl=LspDiagnosticsDefaultWarning linehl= numhl=
sign define LspDiagnosticsSignInformation text=> texthl=LspDiagnosticsDefaultInformation linehl= numhl=
sign define LspDiagnosticsSignHint text=> texthl=LspDiagnosticsDefaultHint linehl= numhl=

lua << EOF
local lsp_status = require('lsp-status')
lsp_status.register_progress()

local lspconfig = require'lspconfig'
lspconfig.ccls.setup{
  root_dir = lspconfig.util.root_pattern(".ccls-root", "meson.build"),
  on_attach = lsp_status.on_attach,
  capabilities = lsp_status.capabilities
}
lspconfig.rust_analyzer.setup{
  on_attach = lsp_status.on_attach,
  capabilities = lsp_status.capabilities
}
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
  }
)
EOF

"
" definitions
nnoremap <silent> <Space>gg <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> <Space>gd <cmd>lua vim.lsp.buf.peek_definition()<CR>
nnoremap <silent> <Space>gr <cmd>lua vim.lsp.buf.references()<CR>

nnoremap <silent> <Space>en <cmd>lua vim.lsp.diagnostic.goto_next({severity='Error'})<CR>
nnoremap <silent> <Space>ep <cmd>lua vim.lsp.diagnostic.goto_prev({severity='Error'})<CR>
" nnoremap <silent> <Space>el <cmd>lua vim.lsp.diagnostic.set_loclist({severity='Error'})<CR>
nnoremap <silent> <Space>el <cmd>Telescope lsp_workspace_diagnostics<CR>
nnoremap <silent> <Space>in <cmd>lua vim.lsp.diagnostic.goto_next({severity='Information'})<CR>
nnoremap <silent> <Space>ip <cmd>lua vim.lsp.diagnostic.goto_prev({severity='Information'})<CR>
nnoremap <silent> <Space>il <cmd>lua vim.lsp.diagnostic.set_loclist({severity='Information'})<CR>
nnoremap <silent> <Space>wn <cmd>lua vim.lsp.diagnostic.goto_next({severity='Warning'})<CR>
nnoremap <silent> <Space>wp <cmd>lua vim.lsp.diagnostic.goto_prev({severity='Warning'})<CR>
nnoremap <silent> <Space>wl <cmd>lua vim.lsp.diagnostic.set_loclist({severity='Warning'})<CR>
nnoremap <silent> <Space><Space> <cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>
nnoremap <silent> <Space>F <cmd>lua vim.lsp.buf.formatting_sync()<CR>

" nnoremap <silent> <Space>gd <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-h> <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
"

" allows live preview of find and replace
set inccommand=nosplit
nmap <silent> <leader>/ :nohlsearch<CR>

" Allows you to save files you opened without write permissions via sudo
cmap w!! w !sudo tee %

" === Search === "
" ignore case when searching
set ignorecase

" if the search string has an upper case letter in it, the search will be case sensitive
set smartcase

" Automatically re-read file if a change was detected outside of vim
set autoread

" Enable line numbers
set relativenumber

" Set persistent undo
set undodir=~/.local/share/nvim/undo " Don't put undo files in current dir
set undofile
set undolevels=3000
set undoreload=10000

set backupdir=~/.local/share/nvim/backup " Don't put backups in current dir
set backup
set noswapfile

function! SynGroup()
  let l:s = synID(line('.'), col('.'), 1)
  echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfun
nnoremap <leader>ls :call SynGroup()<CR>

let g:indentLine_char = '▏'
" colorizer setup
" lua require'colorizer'.setup()
" set listchars=eol:↵,trail:~,tab:>-,nbsp:␣
"
" haskell mode setup
let g:haskell_classic_highlighting = 1
let g:haskell_enable_quantification = 1   " to enable highlighting of `forall`
let g:haskell_enable_recursivedo = 1      " to enable highlighting of `mdo` and `rec`
let g:haskell_enable_arrowsyntax = 1      " to enable highlighting of `proc`
let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of `pattern`
let g:haskell_enable_typeroles = 1        " to enable highlighting of type roles
let g:haskell_enable_static_pointers = 1  " to enable highlighting of `static`
let g:haskell_backpack = 1                " to enable highlighting of backpack keywords

nnoremap <silent><leader>si <cmd>lua require('fuzzy_finder').searchInProjectInteractive()<CR>
nnoremap <silent><leader>sw <cmd>lua require('fuzzy_finder').searchInProject(vim.fn.expand('<cword>'))<CR>
nnoremap <silent><leader>slw :lgetexpr system("rg --vimgrep --smart-case -w " . expand('<cword>') . " " . FindGitRoot())<cr>

nnoremap <silent><leader>pf <cmd>lua require('fuzzy_finder').projectFiles()<CR>
nnoremap <silent><leader>bb <cmd>lua require('fuzzy_finder').recentBuffers()<CR>

nnoremap L $
nnoremap H _

nnoremap <silent><leader>ht <cmd>Telescope help_tags<cr>

nnoremap <leader>e :e <C-R>=expand("%:p:h") . "/" <CR>


" dadbod stuff
xnoremap <expr> <Plug>(DBExe)     db#op_exec()
nnoremap <expr> <Plug>(DBExe)     db#op_exec()
nnoremap <expr> <Plug>(DBExeLine) db#op_exec() . '_'

xmap <leader>db  <Plug>(DBExe)
nmap <leader>db  <Plug>(DBExe)
omap <leader>db  <Plug>(DBExe)
nmap <leader>dbb <Plug>(DBExeLine)

nmap <Space>ble <Plug>(Luadev-RunLine)
xmap <Space>ble <Plug>(Luadev-Run)

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

nnoremap <silent> <leader>tn :tabnext<CR>

set shada=!,'1000,<500,s100,h
" all the fzf and the sk stuff works well with a fast shell
set shell=/bin/dash

set completeopt=menuone,noselect
highlight link CompeDocumentation NormalFloat



lua << EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  }
}


require('telescope').setup{
  defaults = {
    sorting_strategy = 'ascending',
    layout_config = {
      prompat_position = 'top',
      width = 0.7,
    }
  };
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = false, -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    }
  }
}

require'lualine'.setup{
  options = { theme  = 'onedark' },
  sections = {
    lualine_a = {'mode'},
    lualine_b = { 'filename','filetype' },
    lualine_c = {
      require'lsp-status'.status
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },a
}
local lsp=require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

-- (Optional) Configure lua language server for neovim
lsp.nvim_workspace()

lsp.setup()
EOF
" nnoremap <silent><leader>pf <cmd>lua require('telescope.builtin').find_files({search_dirs={require('fuzzy_finder').getGitRoot()}})<CR>
" nnoremap <silent><leader>sw <cmd>lua require('telescope.builtin').grep_string({search_dirs={require('fuzzy_finder').getGitRoot()}})<CR>

" see: https://github.com/voldikss/vim-floaterm/issues/82
" without this floating window leaves an empty buffer when
" invoked from the startify page
autocmd User Startified setlocal buflisted
"coc config"

