local o = vim.opt

o.number = true
o.relativenumber = true
o.clipboard = "unnamedplus" -- system clipboard
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true
o.ignorecase = true
o.smartcase = true
o.termguicolors = true
o.signcolumn = "yes"
o.cursorline = true
o.scrolloff = 8
o.splitright = true
o.splitbelow = true
o.undofile = true
o.updatetime = 250
o.wrap = false
o.autoindent = true
-- Python = 4 spaces, JS/TS/React/web = 2 spaces
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"json",
		"html",
		"css",
		"yaml",
		"lua",
	},
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
	end,
})

-- Django templates
vim.filetype.add({
	pattern = { [".*/templates/.*%.html"] = "htmldjango" },
})
