vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- nvim-tree replaces netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("config.options")
require("config.keymaps")
require("config.lazy")
