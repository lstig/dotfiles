# zsh package

Stow package for zsh configuration. Installs `~/.zshenv` (which redirects
`ZDOTDIR` to `~/.config/zsh`) and the actual config tree under
`~/.config/zsh/`.

## Structure

```
.zshenv                   # sets ZDOTDIR=~/.config/zsh, exports core env
.config/zsh/
├── .zshrc                # main interactive config
├── conf.d/               # modular fragments, sourced in lexical order
│   ├── 10-aliases.zsh
│   ├── 20-gpg.zsh
│   ├── 30-pnpm.zsh
│   ├── 31-lesspipe.zsh
│   ├── 32-orbstack.sh
│   ├── 40-atuin.zsh
│   └── 99-starship.zsh
└── custom/
    └── plugins/          # locally-vendored zsh plugins
.config/atuin/
└── config.toml           # atuin client config (see "Atuin sync" below)
```

Fragments under `conf.d/` are numbered so load order is explicit; keep the
numbering scheme contiguous when adding new ones.

## Atuin sync

Shell history sync uses a self-hosted atuin server rather than the atuin.sh
cloud service, tracked separately in the `k8s-apps` repo (Joplin task
`[0005] Set up self-hosted atuin sync server`). Until that server exists,
`40-atuin.zsh` only wires up local history (no `atuin login`/`atuin
register`); running one of those against the self-hosted server's address is
the last step of task `[0005]`.

`40-atuin.zsh` inlines the output of `atuin init zsh` rather than `eval`-ing
it at shell startup, per the repo's no-`eval`-in-shell-init policy (see
[ADR 0003](../docs/adr/0003-avoid-eval-in-shell-init.md)). It must be
manually regenerated after upgrading atuin.

`.config/atuin/config.toml` is the client config, copied from
`~/.config/atuin/config.toml`. Customized beyond stock: `search_mode =
"skim"`, `style = "compact"` with `inline_height` (and the up-key variant)
set to `10` to keep the popup to roughly 5-10 visible commands, and
`history_filter = ["^yt-dl"]` mirroring the zsh `HISTORY_IGNORE` pattern in
`.zshrc` (keep the two in sync if either changes). There's no `server.toml`
yet since the self-hosted server (task `[0005]`) doesn't exist; add it here
once it does. Atuin's data directory (`~/.local/share/atuin/`: `history.db`,
`key`, `meta.db`, etc.) is Machine-mutated state, not repo content — never
commit it.
