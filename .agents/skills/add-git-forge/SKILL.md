---
name: add-git-forge
description: Add a per-forge git identity (host + email) to the git stow package. Use when the user wants a new code forge (GitHub, GitLab, Codeberg, a self-hosted instance, etc.) to commit under a specific email, selected automatically by remote URL.
---

# add-git-forge

Wires up a new code forge so that any repo whose remote points at that host
commits under a chosen identity. Identity is selected by matching the remote
URL via `includeIf "hasconfig:remote.*.url:..."` in `git/.gitconfig`, with the
email kept in a small per-forge file under `git/.config/git/`.

## Layout

```
git/.gitconfig                 # main config + per-forge includeIf blocks
git/.config/git/<forge>        # [user] email = ... for that forge
git/.config/git/allowed_signers # email -> signing key, for local verification
```

Each forge has **one** email file, **three** `includeIf` blocks (see below),
and **one** `allowed_signers` line mapping its email to the signing key.

## The glob gotcha (why three patterns)

`hasconfig:remote.*.url:<glob>` matches the whole remote URL with git's
`wildmatch`. A leading `**` only crosses `/` when it is **followed by a slash**;
`**host/**` degrades to a plain `*`, which cannot span the `//` and `@` in
`ssh://git@host/…`, so it silently never matches. Anchor the scheme (or the
scp `host:` prefix) instead. Cover all three real-world URL forms:

| Remote URL form                         | Pattern                  |
| --------------------------------------- | ------------------------ |
| `ssh://…/`, `https://…/` (no port)      | `*://**HOST/**`          |
| `ssh://…:PORT/` (explicit port)         | `*://**HOST:*/**`        |
| scp-style `[user@]HOST:owner/repo.git`  | `*HOST:*/**`             |

Note: scp root-level repos (`HOST:repo.git`, no `owner/`) won't match — forges
always use `owner/repo`, so this is fine in practice.

## Steps

1. **Gather inputs** — ask if not provided:
   - `<forge>`: short file name, e.g. `github`, `gitlab`, `codeberg`, `local`.
   - `HOST`: the remote host, e.g. `github.com`, `git.example.com`.
   - `EMAIL`: the identity for that forge (often a `…@users.noreply.<host>`
     address).

2. **Create the email file** in the git package:
   ```bash
   DOTFILES=$(git rev-parse --show-toplevel)
   cat > "$DOTFILES/git/.config/git/<forge>" <<EOF
   [user]
       email = <EMAIL>
   EOF
   ```

3. **Add the three `includeIf` blocks** to `git/.gitconfig`, grouped with the
   existing forge blocks (substitute `HOST` and `<forge>`):
   ```gitconfig
   [includeIf "hasconfig:remote.*.url:*://**HOST/**"]
       path = ~/.config/git/<forge>
   [includeIf "hasconfig:remote.*.url:*://**HOST:*/**"]
       path = ~/.config/git/<forge>
   [includeIf "hasconfig:remote.*.url:*HOST:*/**"]
       path = ~/.config/git/<forge>
   ```

4. **Add an `allowed_signers` line** so commits made under `<EMAIL>` verify
   locally (`git log --show-signature`, `git verify-commit`). Git matches the
   committer email as the principal, so each email needs its own entry mapping
   to the signing public key. One line per email (same key is fine):
   ```bash
   printf '%s %s\n' "<EMAIL>" "$(cat ~/.ssh/id_rsa.pub | cut -d' ' -f1-2)" \
     >> "$DOTFILES/git/.config/git/allowed_signers"
   ```
   This is only for *local* verification — forges verify against the key
   uploaded to your account, not this file. Skip only if the forge identity
   signs with a different key (then add that key's line instead).

5. **Re-stow** so the new email file is symlinked into `$HOME` (the `.gitconfig`
   symlink already exists, but a brand-new `.config/git/<forge>` file is not):
   ```bash
   stow -v -R -t "$HOME" -d "$DOTFILES" git
   ```

6. **Verify** the identity resolves for each URL form, without touching real
   repos:
   ```bash
   for url in \
     "ssh://git@HOST/owner/repo.git" \
     "git@HOST:owner/repo.git" \
     "https://HOST/owner/repo.git"; do
     d=$(mktemp -d); git -C "$d" init -q; git -C "$d" remote add origin "$url"
     printf '%-45s -> %s\n' "$url" "$(git -C "$d" config --get user.email || echo NO-MATCH)"
     rm -rf "$d"
   done
   ```
   All three must print `<EMAIL>`. Confirm the signer entry too:
   ```bash
   git config get user.signingkey >/dev/null && \
     grep -q "<EMAIL>" ~/.config/git/allowed_signers && echo "signer OK"
   ```

7. **Update `git/CONTEXT.md`** — add the new forge to the structure listing.

8. **Stage and show the diff**, then commit with a scoped conventional message
   (e.g. `feat(git): add <forge> identity`). Do not commit unless asked.

## Notes

- The email files and `allowed_signers` contain no secrets — only public
  identity addresses and public keys.
- Multiple `includeIf` blocks pointing at the same file is intentional and
  harmless; later includes simply re-set the same value.
- To find a forge's privacy email, check the forge's account/email settings for
  a `…@users.noreply.<host>` (or equivalent) address.
