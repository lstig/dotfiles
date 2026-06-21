# forgejo-cli package

Stow package for [forgejo-cli](https://codeberg.org/forgejo-contrib/forgejo-cli) configuration.

## Layout

```
forgejo-cli/
├── CONTEXT.md                  # this file (not stowed)
├── .stow-local-ignore          # excludes CONTEXT.md from stow
└── .config/
    └── forgejo-cli/            # → ~/.config/forgejo-cli/
```

## Contents

`~/.config/forgejo-cli/` holds forgejo-cli's config file (typically `config.toml` or similar).
Add config files under `.config/forgejo-cli/` in this package and they will be symlinked into place.

## Stow

```sh
# From repo root
stow -v -t "$HOME" forgejo-cli

# Re-stow after changes
stow -v -R -t "$HOME" forgejo-cli
```
