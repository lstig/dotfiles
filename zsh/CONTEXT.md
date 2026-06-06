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
│   └── 99-starship.zsh
└── custom/
    └── plugins/          # locally-vendored zsh plugins
```

Fragments under `conf.d/` are numbered so load order is explicit; keep the
numbering scheme contiguous when adding new ones.
