return {
	-- auto-close (), [], {}, "", ''
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
	},
	-- auto-close and auto-rename HTML/JSX tags (useful for React)
	{
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		opts = {},
	},
}
