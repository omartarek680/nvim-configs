# nvim-config

My Neovim setup for full stack development with **Django / Django REST Framework** and **React**.
Built on [lazy.nvim](https://github.com/folke/lazy.nvim), with LSP, completion, formatting, Telescope, a file tree and icons.

<!-- Add a screenshot here: ![screenshot](screenshot.png) -->

## Features

- **Python / DRF**: Pyright (type checking off) and Ruff for completion, navigation, linting and formatting
- **React / JS / TS**: `ts_ls`, ESLint, Prettier, HTML/CSS servers, Emmet, auto-closing JSX tags
- **Completion**: blink.cmp (Enter accepts the selected item)
- **Search and files**: Telescope (with fzf) and nvim-tree
- **Git**: gitsigns in the sign column
- **UI**: Catppuccin (mocha), lualine and file icons
- **Quality of life**: format on save, auto-pairs, system clipboard, Django terminal shortcuts

## Requirements

- Neovim **0.11 or newer**
- `git`, `curl`, `unzip`, `gcc`, `make`
- `ripgrep` (for live grep), `node` and `npm` (for the TypeScript server and Prettier)
- A [Nerd Font](https://www.nerdfonts.com/) set as your terminal font (for icons)

Fedora one-liner for the packages:

```bash
sudo dnf install -y neovim git gcc gcc-c++ make unzip curl ripgrep fd-find nodejs npm
```

## Install

Back up any existing config first:

```bash
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
```

Clone and start Neovim:

```bash
git clone https://github.com/omartarek680/nvim-config.git ~/.config/nvim
nvim
```

On first launch, lazy.nvim installs the plugins and Mason installs the language servers and formatters. Wait for it to finish (check progress with `:Lazy` and `:Mason`), then restart Neovim.

### Install the font (for icons)

```bash
mkdir -p ~/.local/share/fonts/JetBrainsMonoNerd
curl -fL -o /tmp/JetBrainsMono.zip \
  https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMonoNerd
fc-cache -f
```

Then set your terminal font to **JetBrainsMono Nerd Font** and restart the terminal. In Xfce Terminal: Edit, Preferences, Appearance, untick "Use system font".

## Structure

```
nvim
├── init.lua                  entry point (leader key, loads config)
├── lazy-lock.json            pinned plugin versions
└── lua
    ├── config
    │   ├── lazy.lua          lazy.nvim bootstrap
    │   ├── options.lua       editor options, diagnostic icons
    │   └── keymaps.lua       custom keymaps
    └── plugins
        ├── autopairs.lua     auto-close brackets, quotes and tags
        ├── catppuccin.lua    colorscheme
        ├── completion.lua    blink.cmp
        ├── formatting.lua    conform.nvim (format on save)
        ├── git.lua           gitsigns
        ├── icons.lua         nvim-web-devicons
        ├── lsp.lua           language server settings and LSP keymaps
        ├── lualine.lua       status line
        ├── mason.lua         installs language servers and tools
        ├── nvim-tree.lua     file explorer
        ├── telescope.lua     fuzzy finder
        └── treesitter.lua    syntax highlighting
```

Each file in `lua/plugins/` is one plugin spec, loaded automatically by lazy.nvim.

## Key bindings

The leader key is **Space**.

| Keys | Action |
|---|---|
| `Space e` | Toggle file tree |
| `Space ff` / `Space fg` / `Space fb` | Find files / grep project / buffers |
| `Space w` | Save |
| `gd` / `gr` / `K` | Definition / references / hover |
| `Space rn` / `Space ca` | Rename / code action |
| `Space rs` | Django runserver |
| `Space rm` | Django makemigrations + migrate |
| `Space rt` | Django tests |

See [CHEATSHEET.md](CHEATSHEET.md) for the full list of keys and commands.

## Django tips

- Run `pipenv shell` in your project, then start `nvim` from the project root, so Pyright can find your installed packages.
- Templates under a `templates/` folder get the `htmldjango` filetype automatically.

## Customizing

- Add a plugin: create a new file in `lua/plugins/` that returns a plugin spec.
- Add a language server: add its name to `ensure_installed` in `mason.lua` and to the `vim.lsp.enable` list in `lsp.lua`.
- Add a formatter: install it with `:Mason` and register it in `formatting.lua`.

## Troubleshooting

| Problem | Fix |
|---|---|
| Boxes instead of icons | Set a Nerd Font as the terminal font and restart the terminal |
| `module 'nvim-treesitter.configs' not found` | Keep `branch = "master"` in `treesitter.lua`, delete `~/.local/share/nvim/lazy/nvim-treesitter` and run `:Lazy sync` |
| LSP errors about `vim.lsp.enable` | Neovim is older than 0.11; upgrade it |
| Python imports flagged as missing | Start nvim from inside `pipenv shell` |
| Live grep does nothing | Install `ripgrep` |

## Publishing your own copy

```bash
cd ~/.config/nvim
git init
git add .
git commit -m "Initial Neovim config"
git branch -M main
git remote add origin https://github.com/<your-username>/nvim-config.git
git push -u origin main
```

Commit `lazy-lock.json` so everyone gets the same plugin versions.

## License

MIT
