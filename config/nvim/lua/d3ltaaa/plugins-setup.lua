local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootsrap = ensure_packer() --true if packer was just installed

-- autocommand that reloads neovim whenever you save this file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

local status, packer = pcall(require, "packer")
if not status then 
    return
end



return packer.startup(function(use)
    
    use("wbthomason/packer.nvim")

    -- plugin dependency
    use("nvim-lua/plenary.nvim") -- lua functions that many plugins use

    use("szw/vim-maximizer") -- maximizes and restores current window
    
    -- essential plugins
    use("tpope/vim-surround") -- add, delete, change surroundings (it's awesome) --> 'csw"'
    use("inkarkat/vim-ReplaceWithRegister") -- replace with register contents using motion (gr + motion)

    -- commenting with gc
    use("numToStr/Comment.nvim")

    -- file explorer
    use("nvim-tree/nvim-tree.lua")

    -- icons
    use("nvim-tree/nvim-web-devicons") -- did not change anythin

    -- status line
    use("nvim-lualine/lualine.nvim")

    -- fuzzy finding
    use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" }) -- dependency for better sorting performance
    use({ "nvim-telescope/telescope.nvim", branch = "0.1.x" }) -- fuzzy finder

    use("norcalli/nvim-colorizer.lua")

    use("shaunsingh/nord.nvim")


    if packer_bootstrap then
        require("packer").sync()
    end
end)
