# direnv package

Stow package for [direnv](https://direnv.net) configuration. Installs
`~/.config/direnv/`.

## Structure

```
.config/direnv/
├── direnv.toml             # global direnv config (env diff, timeouts, strict_env)
└── direnvrc                # shell hook sourced before every .envrc
```

`direnv.toml` holds machine-wide defaults under `[global]`. `direnvrc` runs
before each project's `.envrc` and sources `~/.envrc` (when present and not in
`$HOME`) so global env applies everywhere. Per-project behavior lives in each
project's own `.envrc` (not managed here).
