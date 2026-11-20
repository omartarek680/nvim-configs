return {
  { "mason-org/mason.nvim", opts = {} },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = {
        "pyright", "ruff",                          -- Python / DRF
        "ts_ls", "eslint",                          -- React / JS / TS
        "html", "cssls", "emmet_language_server",
        "jsonls", "lua_ls", "dockerls",
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = { ensure_installed = { "prettier", "stylua" } },
  },
}
