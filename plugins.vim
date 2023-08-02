" ============================================================================ "
" ===                               PLUGINS                                === "
" ============================================================================ "

" check whether vim-plug is installed and install it if necessary
let plugpath = expand('<sfile>:p:h'). '/autoload/plug.vim'
if !filereadable(plugpath)
    if executable('curl')
        let plugurl = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        call system('curl -fLo ' . shellescape(plugpath) . ' --create-dirs ' . plugurl)
        if v:shell_error
            echom "Error downloading vim-plug. Please install it manually.\n"
            exit
        endif
    else
        echom "vim-plug not installed. Please install it manually or install curl.\n"
        exit
    endif
endif

call plug#begin('~/.config/nvim/plugged')

" === Editing Plugins === "
" Trailing whitespace highlighting & automatic fixing
" Plug 'ntpeters/vim-better-whitespace'

" auto-close plugin
" Plug 'rstacruz/vim-closer'

" Improved motion in Vim
" Plug 'easymotion/vim-easymotion'
" Plug 'justinmk/vim-sneak'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
" To work with word casing
Plug 'tpope/vim-abolish'

" Plug 'mhinz/vim-signify'
" Plug 'tpope/vim-fugitive'

" Syntax highlighting for nginx
Plug 'chr4/nginx.vim'

" Colorscheme
Plug 'joshdick/onedark.vim'

" instead of netrw
Plug 'justinmk/vim-dirvish'

" Startup
Plug 'mhinz/vim-startify'

Plug 'tpope/vim-commentary'

" Haskell filetype plugin

" colorizer
" Plug 'norcalli/nvim-colorizer.lua'

Plug 'norcalli/nvim.lua'

" lsp
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/lsp-status.nvim'

" Plugin development
Plug 'bfredl/nvim-luadev'

" easymotion like
" Plug 'justinmk/vim-sneak'

" database access
Plug 'tpope/vim-dadbod'

" vim fugitive
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-markdown'

" yaml syntax
Plug 'stephpy/vim-yaml'

" Plug 'vigemus/impromptu.nvim'
Plug 'junegunn/vim-easy-align'
Plug 'tami5/sql.nvim'
" Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" Plug 'hrsh7th/nvim-compe'

Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

Plug 'hoob3rt/lualine.nvim'
Plug  'vim-airline/vim-airline'
Plug  'preservim/nerdtree'

" LSP Support
Plug 'neovim/nvim-lspconfig'             " Required
Plug 'williamboman/mason.nvim'           " Optional
Plug 'williamboman/mason-lspconfig.nvim' " Optional

" Autocompletion Engine
Plug 'hrsh7th/nvim-cmp'         " Required
Plug 'hrsh7th/cmp-nvim-lsp'     " Required
Plug 'hrsh7th/cmp-buffer'       " Optional
Plug 'hrsh7th/cmp-path'         " Optional
Plug 'saadparwaiz1/cmp_luasnip' " Optional
Plug 'hrsh7th/cmp-nvim-lua'     " Optional

"  Snippets
Plug 'L3MON4D3/LuaSnip'             " Required
Plug 'rafamadriz/friendly-snippets' " Optional

Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v1.x'}
" Initialize plugin system"

call plug#end()
