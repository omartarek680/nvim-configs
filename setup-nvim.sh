#!/usr/bin/env bash
# setup-nvim-v2.sh — complete Neovim config for Django/DRF + React (lazy.nvim)
#
# Usage:
#   bash setup-nvim-v2.sh                 # write config + install plugins
#   bash setup-nvim-v2.sh --deps          # also install system packages (Fedora/dnf)
#   bash setup-nvim-v2.sh --font          # also install JetBrainsMono Nerd Font (icons)
#   bash setup-nvim-v2.sh --deps --font   # everything
#
# Your current config is backed up first. lazy-lock.json is never touched.

set -euo pipefail

INSTALL_DEPS=0
INSTALL_FONT=0
for arg in "$@"; do
  case "$arg" in
    --deps) INSTALL_DEPS=1 ;;
    --font) INSTALL_FONT=1 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

# ---------- system dependencies (Fedora) ----------
if [[ $INSTALL_DEPS -eq 1 ]]; then
  echo "==> Installing system dependencies (needs sudo)..."
  sudo dnf install -y neovim git gcc gcc-c++ make unzip curl ripgrep fd-find nodejs npm
fi

# ---------- sanity checks ----------
if ! command -v nvim >/dev/null 2>&1; then
  echo "ERROR: nvim is not installed. Run with --deps or: sudo dnf install -y neovim" >&2
  exit 1
fi

ver="$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
if [[ "$(printf '%s\n' 0.11.0 "$ver" | sort -V | head -n1)" != "0.11.0" ]]; then
  echo "WARNING: Neovim $ver detected. This config needs 0.11+ (vim.lsp.enable)." >&2
  echo "         Upgrade Neovim, otherwise lsp.lua will error." >&2
fi

for cmd in git curl; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "ERROR: '$cmd' is required." >&2; exit 1; }
done
command -v rg   >/dev/null 2>&1 || echo "NOTE: ripgrep missing (Telescope live_grep): sudo dnf install ripgrep"
command -v node >/dev/null 2>&1 || echo "NOTE: node missing (ts_ls, prettier): sudo dnf install nodejs npm"
command -v make >/dev/null 2>&1 || echo "NOTE: make/gcc missing (fzf-native, Treesitter): sudo dnf install make gcc"

# ---------- Nerd Font (icons) ----------
if [[ $INSTALL_FONT -eq 1 ]]; then
  if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd"; then
    echo "==> JetBrainsMono Nerd Font already installed."
  else
    echo "==> Installing JetBrainsMono Nerd Font..."
    command -v unzip >/dev/null 2>&1 || { echo "ERROR: unzip is required for --font." >&2; exit 1; }
    mkdir -p "$HOME/.local/share/fonts/JetBrainsMonoNerd"
    tmp="$(mktemp -d)"
    curl -fL -o "$tmp/JetBrainsMono.zip" \
      https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip -oq "$tmp/JetBrainsMono.zip" -d "$HOME/.local/share/fonts/JetBrainsMonoNerd"
    rm -rf "$tmp"
    fc-cache -f
    echo "    Done. Set your terminal font to 'JetBrainsMono Nerd Font' (Xfce Terminal:"
    echo "    Edit > Preferences > Appearance > untick 'Use system font')."
  fi
fi

# ---------- backup ----------
if [[ -d "$NVIM_DIR" ]]; then
  backup="${NVIM_DIR}.bak.$(date +%Y%m%d-%H%M%S)"
  cp -a "$NVIM_DIR" "$backup"
  echo "==> Backed up existing config to: $backup"
fi

# write_file <relative path>   (content comes from stdin; always overwrites)
write_file() {
  local path="$NVIM_DIR/$1"
  mkdir -p "$(dirname "$path")"
  cat > "$path"
  echo "  wrote: $1"
}

echo "==> Writing config to $NVIM_DIR"

# ======================================================================
# init.lua
# ======================================================================
write_file init.lua <<'LUA_EOF'
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- nvim-tree replaces netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("config.options")
require("config.keymaps")
require("config.lazy")
LUA_EOF

# ======================================================================
# lua/config/lazy.lua
# ======================================================================
write_file lua/config/lazy.lua <<'LUA_EOF'
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  change_detection = { notify = false },
})
LUA_EOF

# ======================================================================
# lua/config/options.lua
# ======================================================================
write_file lua/config/options.lua <<'LUA_EOF'
local o = vim.opt

o.number = true
o.relativenumber = true
o.clipboard = "unnamedplus"      -- system clipboard
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.autoindent = true
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

-- Python = 4 spaces, JS/TS/React/web = 2 spaces
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "javascript", "javascriptreact", "typescript", "typescriptreact",
    "json", "html", "css", "yaml", "lua",
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

-- Diagnostic icons (needs a Nerd Font in the terminal)
local sign = function(code) return vim.fn.nr2char(code) .. " " end
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = sign(0xf057),
      [vim.diagnostic.severity.WARN]  = sign(0xf071),
      [vim.diagnostic.severity.INFO]  = sign(0xf05a),
      [vim.diagnostic.severity.HINT]  = sign(0xf0eb),
    },
  },
})
LUA_EOF

# ======================================================================
# lua/config/keymaps.lua
# ======================================================================
write_file lua/config/keymaps.lua <<'LUA_EOF'
local map = vim.keymap.set

-- files / search
map("n", "<leader>e",  "<cmd>NvimTreeToggle<cr>",        { desc = "Toggle file tree" })
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>",  { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>",   { desc = "Grep in project" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>",     { desc = "Buffers" })

-- basics
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Django helpers (run from the project root, inside `pipenv shell`)
map("n", "<leader>rs", "<cmd>belowright split | terminal python manage.py runserver<cr>",
  { desc = "Django runserver" })
map("n", "<leader>rm", "<cmd>belowright split | terminal python manage.py makemigrations && python manage.py migrate<cr>",
  { desc = "Django makemigrations + migrate" })
map("n", "<leader>rt", "<cmd>belowright split | terminal python manage.py test<cr>",
  { desc = "Django tests" })
LUA_EOF

# ======================================================================
# lua/plugins/catppuccin.lua
# ======================================================================
write_file lua/plugins/catppuccin.lua <<'LUA_EOF'
return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({ flavour = "mocha" })
    vim.cmd.colorscheme("catppuccin")
  end,
}
LUA_EOF

# ======================================================================
# lua/plugins/icons.lua
# ======================================================================
write_file lua/plugins/icons.lua <<'LUA_EOF'
return {
  "nvim-tree/nvim-web-devicons",
  lazy = true,
  opts = {},
}
LUA_EOF

# ======================================================================
# lua/plugins/lualine.lua
# ======================================================================
write_file lua/plugins/lualine.lua <<'LUA_EOF'
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = { options = { theme = "auto" } },
}
LUA_EOF

# ======================================================================
# lua/plugins/mason.lua
# ======================================================================
write_file lua/plugins/mason.lua <<'LUA_EOF'
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
LUA_EOF

# ======================================================================
# lua/plugins/lsp.lua   (Neovim 0.11+ API; type checking disabled)
# ======================================================================
write_file lua/plugins/lsp.lua <<'LUA_EOF'
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
LUA_EOF

# ======================================================================
# lua/plugins/completion.lua   (Enter accepts the selected item)
# ======================================================================
write_file lua/plugins/completion.lua <<'LUA_EOF'
return {
  "saghen/blink.cmp",
  version = "1.*",
  opts = {
    keymap = { preset = "enter" },   -- Enter accepts; Ctrl-n / Ctrl-p move
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
  },
}
LUA_EOF

# ======================================================================
# lua/plugins/formatting.lua
# ======================================================================
write_file lua/plugins/formatting.lua <<'LUA_EOF'
return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  opts = {
    formatters_by_ft = {
      python = { "ruff_format", "ruff_organize_imports" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      css = { "prettier" },
      html = { "prettier" },
      lua = { "stylua" },
    },
    format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
  },
}
LUA_EOF

# ======================================================================
# lua/plugins/autopairs.lua
# ======================================================================
write_file lua/plugins/autopairs.lua <<'LUA_EOF'
return {
  -- auto-close (), [], {}, "", ''
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  -- auto-close and auto-rename HTML/JSX tags
  { "windwp/nvim-ts-autotag", event = "InsertEnter", opts = {} },
}
LUA_EOF

# ======================================================================
# lua/plugins/nvim-tree.lua
# ======================================================================
write_file lua/plugins/nvim-tree.lua <<'LUA_EOF'
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    filters = { dotfiles = false },
    git = { ignore = false },
  },
}
LUA_EOF

# ======================================================================
# lua/plugins/telescope.lua
# ======================================================================
write_file lua/plugins/telescope.lua <<'LUA_EOF'
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        file_ignore_patterns = { "node_modules", "%.git/", "__pycache__", "venv", "%.venv" },
      },
    })
    pcall(telescope.load_extension, "fzf")
  end,
}
LUA_EOF

# ======================================================================
# lua/plugins/treesitter.lua   (master branch; indent module off)
# ======================================================================
write_file lua/plugins/treesitter.lua <<'LUA_EOF'
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  main = "nvim-treesitter.configs",
  opts = {
    ensure_installed = {
      "python", "javascript", "typescript", "tsx", "html", "css",
      "json", "yaml", "toml", "sql", "lua", "bash", "dockerfile", "markdown",
    },
    highlight = { enable = true },
    indent = { enable = false },   -- built-in indenting works better for Python
  },
}
LUA_EOF

# ======================================================================
# lua/plugins/git.lua
# ======================================================================
write_file lua/plugins/git.lua <<'LUA_EOF'
return {
  "lewis6991/gitsigns.nvim",
  opts = {},
}
LUA_EOF

# ======================================================================
# .gitignore (for publishing the config on GitHub)
# ======================================================================
write_file .gitignore <<'GIT_EOF'
*.bak*
.DS_Store
GIT_EOF

# ---------- fix a Treesitter checkout left on the old 'main' branch ----------
ts_dir="$HOME/.local/share/nvim/lazy/nvim-treesitter"
if [[ -d "$ts_dir/.git" ]]; then
  branch="$(git -C "$ts_dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")"
  if [[ "$branch" != "master" ]]; then
    echo "==> Removing old nvim-treesitter checkout (branch: ${branch:-unknown}); it will be re-cloned on 'master'"
    rm -rf "$ts_dir"
  fi
fi

# ---------- install plugins ----------
echo "==> Installing plugins (lazy.nvim sync)..."
nvim --headless "+Lazy! sync" +qa || echo "NOTE: plugin sync had issues; open nvim and run :Lazy to check."

echo
echo "Done. Open Neovim with:  nvim"
echo "First launch: Mason installs the language servers (watch with :Mason)."
echo "Django: run 'pipenv shell' in your project, then start nvim from the project root."
echo "Icons: set your terminal font to 'JetBrainsMono Nerd Font' (use --font to install it)."
