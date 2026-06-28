# git package

Stow package for git configuration. Installs `~/.gitconfig` and
`~/.config/git/`.

## Structure

```
.gitconfig                  # main git config (user, signing, includes)
.config/git/
├── ignore                  # global .gitignore
├── allowed_signers         # SSH signing allowed signers
├── github                  # GitHub-specific email (includeIf)
├── gitlab                  # GitLab-specific email (includeIf)
├── codeberg                # Codeberg-specific email (includeIf)
└── local                   # self-hosted Gitea email (includeIf)
```

The per-forge files are sourced via `includeIf "hasconfig:remote.*.url:..."`
directives in `.gitconfig`, so the identity is selected by matching a repo's
remote URL rather than its on-disk location. Each forge has three blocks to
cover `ssh://`/`https://`, ported, and scp-style (`git@host:owner/repo`) URLs;
a bare leading `**host/**` glob silently fails to match `ssh://git@host/…`, so
the scheme/`host:` prefix must be anchored.

To add a new forge, use the `add-git-forge` skill.
