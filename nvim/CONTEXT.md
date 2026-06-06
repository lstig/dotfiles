# nvim package

Stow package for Neovim configuration. Installs `~/.config/nvim/`.

## Structure

```
.config/nvim/
├── init.lua          # entry point
├── lazy-lock.json    # lazy.nvim plugin lockfile
├── lua/
│   ├── config/       # options, keymaps, autocmds, lazy bootstrap
│   └── plugins/      # plugin specs (one file per plugin or group)
└── after/
    └── ftplugin/     # filetype-specific overrides
```
