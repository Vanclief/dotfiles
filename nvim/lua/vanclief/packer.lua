-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- File navigation
  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.1',
	  -- or                            , branch = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- Theme
  use ('navarasu/onedark.nvim')

  -- AST in steroids
  use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
  use('nvim-treesitter/playground')

  -- Quickly switching between files
  use('ThePrimeagen/harpoon')

  -- CTRL-Z in steroids
  use('mbbill/undotree')

  -- Git Plugin
  use('tpope/vim-fugitive')

  -- LSP Support
  use {
	  'VonHeikemen/lsp-zero.nvim',
	  branch = 'v2.x',
	  requires = {
		  -- LSP Support
		  {'neovim/nvim-lspconfig'},             -- Required
		  {                                      -- Optional
		  'williamboman/mason.nvim',
		  run = function()
			  pcall(vim.cmd, 'MasonUpdate')
		  end,
	  },
	  {'williamboman/mason-lspconfig.nvim'}, -- Optional

	  -- Autocompletion
	  {'hrsh7th/nvim-cmp'},     -- Required
	  {'hrsh7th/cmp-nvim-lsp'}, -- Required
	  {'L3MON4D3/LuaSnip'},     -- Required
	}
  }

  -- Copilot & ChatGPT
  use('github/copilot.vim')

  use({
      "jackMort/ChatGPT.nvim",
      requires = {
          "MunifTanjim/nui.nvim",
          "nvim-lua/plenary.nvim",
          "nvim-telescope/telescope.nvim"
      }
  })

  -- Status Bar
  use('feline-nvim/feline.nvim')

  -- Commenting
  use('numToStr/Comment.nvim')

  -- Tests
  use('vim-test/vim-test')

  -- NvimTree
  use {
      'nvim-tree/nvim-tree.lua',
      requires = {
          'nvim-tree/nvim-web-devicons', -- optional
      }
  }

  -- LSP Magic
  use('jose-elias-alvarez/null-ls.nvim')

end)
