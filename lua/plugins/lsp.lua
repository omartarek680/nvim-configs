return {
  "neovim/nvim-lspconfig",
  dependencies = { "mason-org/mason-lspconfig.nvim", "saghen/blink.cmp" },
  config = function()
    local caps = require("blink.cmp").get_lsp_capabilities()
    vim.lsp.config("*", { capabilities = caps })

    -- Pyright: completion/navigation only, no type checking
    vim.lsp.config("pyright", {
      settings = { python = { analysis = { typeCheckingMode = "off" } } },
    })

    vim.lsp.enable({
      "pyright", "ruff",
      "ts_ls", "eslint",
      "html", "cssls", "emmet_language_server",
      "jsonls", "lua_ls", "dockerls",
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
        local m = function(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
        end
        m("gd", vim.lsp.buf.definition, "Go to definition")
        m("gr", vim.lsp.buf.references, "References")
        m("K", vim.lsp.buf.hover, "Hover docs")
        m("<leader>rn", vim.lsp.buf.rename, "Rename")
        m("<leader>ca", vim.lsp.buf.code_action, "Code action")
        m("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Prev diagnostic")
        m("]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
      end,
    })
  end,
}
