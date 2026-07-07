# ADR 0003: Avoid `eval` in zsh startup files; inline generated output instead

Several tools' setup docs recommend wiring into a shell via
`eval "$(some-tool init zsh)"`. Where that output is a static, deterministic
script for a given tool version, we inline the literal output into the
conf.d fragment instead of `eval`-ing it — `eval` re-parses the output on
every shell startup and hides the actual code from anything reading the
fragment directly (shellcheck, grep, a human skimming the file).

`zsh/.config/zsh/conf.d/40-atuin.zsh` is the motivating example: it inlines
the full output of `atuin init zsh` (currently ~235 lines) behind a comment
marking it as generated, rather than `eval "$(atuin init zsh)"`. `pnpm`
(`30-pnpm.zsh`) and `starship` (`99-starship.zsh`) already followed this
pattern before this ADR existed — neither uses `eval`.

## Consequences

- Inlined fragments drift from what a newer tool version would generate.
  They must be manually regenerated (rerun the tool's init command, replace
  the generated block) after upgrading that tool — there's no automatic
  check that flags a stale copy.

## Exception: `path_helper` in `.zshenv`

`.zshenv` still does `eval "$(... /usr/libexec/path_helper -s)"`. This is a
deliberate exception, not an oversight: `path_helper`'s output isn't a
static generated script — it depends on the current `$PATH` at invocation
time plus the contents of `/etc/paths` and `/etc/paths.d/*`, which macOS
installers (Docker Desktop, Xcode, etc.) add to over time. Freezing its
output would silently stop picking up paths that a future installer expects
`path_helper` to add, and risks baking in whatever happened to be in `$PATH`
at the moment someone captured it. The rest of `brew shellenv`'s output in
`.zshenv` *is* inlined (it's static); `path_helper` is the one part left
dynamic on purpose.
