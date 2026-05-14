# Global agent instructions

These instructions apply to every pi session for this user. Project-level
`AGENTS.md` files take precedence and may relax or override anything here.

## Working style

- Be concise. Prefer direct answers and minimal preamble.
- Before writing code, read the relevant files; do not guess at APIs.
- When making multi-file changes, batch related edits together rather than
  trickling them out one tool call at a time.
- Surface assumptions explicitly when they affect behavior or correctness.

## Editing

- Match the surrounding style (indentation, quoting, naming) of the file you
  are editing. Do not reformat unrelated code.
- Keep diffs small and focused. Avoid drive-by refactors unless asked.
- Don't leave commented-out code or `TODO` markers behind unless the user asks
  for them.

## Shell & system

- Don't run destructive commands (`rm -rf`, force pushes, history rewrites,
  `git clean -fdx`, etc.) without confirming first.
- Prefer `rg` over `grep -r` and `fd` over `find` when available.
- Read files with the `read` tool; don't `cat` large files.

## Dotfiles awareness

Files under `~/.pi/agent/` (including this one) may be symlinks managed by the
dotfiles repo at `~/Code/lstig/dotfiles`. When the user asks to "edit my pi
config" or similar, edit the file at its real path inside that repo so the
change is version-controlled.
