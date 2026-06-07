# Global agent instructions

These apply to every pi session for this user. Project-level `AGENTS.md` files take precedence and may relax or override anything here.

## Communication

- Be concise. Skip preamble and filler ("Great question!", "I'll now…").
- Lead with the answer or the action; supporting detail comes after.
- Surface assumptions explicitly when they affect correctness.
- Ask before kicking off anything that will take more than ~30s of tool use or touches more than a handful of files. For small, obvious tasks, just do it.
- When you finish a task, summarize *what changed* and *what to do next*, not what you were asked to do.

## Editing

- Read before you write. Don't guess at APIs, file paths, or types — open the file or run `rg` first.
- Match surrounding style: indentation, quote style, naming, import order. Don't reformat unrelated code.
- Keep diffs small and focused. No drive-by refactors unless asked.
- Batch related edits into one tool call rather than trickling them out.
- Don't leave commented-out code, debug prints, or `TODO` markers unless explicitly requested.
- Don't add comments that just restate the code. Comments explain *why*.

## Shell & system

- **Never** run destructive commands without confirming: `rm -rf`, `git clean -fdx`, `git push --force` (use `--force-with-lease`), history rewrites, `DROP`/`TRUNCATE`, `kubectl delete`, etc.
- Prefer modern tools when available: `rg` over `grep -r`, `fd` over `find`, `bat` over `cat` for display, `eza` over `ls`, `gh` for GitHub ops, `glab` for GitLab ops, `tea` for Gitea ops.
- Read files with the `read` tool; don't `cat` large files into the chat.
- Don't echo or log values of env vars matching `*_TOKEN`, `*_KEY`, `*_SECRET`, `*_PASSWORD`, the contexts of environment files `.envrc`, `.env`, or anything under `~/.config/op/`, `~/.gnupg/`, `~/.ssh/`, `~/.aws/`.

## Git

- **Never** force push, unless explicitly asked.
- Default to `--force-with-lease` if a force push is genuinely needed.
- Never amend or rebase commits authored by someone else.
- Don't commit on behalf of the user unless asked. When asked, write a Conventional Commits–style message (`type(scope): subject`) and show the staged diff before committing.
- Don't `git add -A` blindly — review what's staged.

## Language & tooling defaults

Unless a project says otherwise:

- **Python:** `uv` for envs and installs; `ruff` for lint/format; `pytest` for tests. Never run `pip install` globally.
- **Node/TS:** `pnpm` for installs; never `npm install` without asking. Respect `packageManager` in `package.json`.
- **Rust:** `cargo` as-is; run `cargo fmt` and `cargo clippy` before declaring done.
- **Go:** `go fmt ./...` and `go vet ./...` before declaring done.
- **Shell:** target `bash`/`zsh` on macOS; quote variables; use `set -euo pipefail` in scripts.
- **YAML:** use `.yaml` for file extension; never `.yml` unless told by the user or overridden by the local project. Run `yamllint` before declaring done.
- **Markdown:** one sentence per line; one blank line between sections (paragraphs, headers, lists, code blocks). Prefer native Markdown syntax over inline HTML.

After making code changes, run the project's check/test command (look for `Makefile`, `Taskfile.yml`, `Taskfile.yaml`, `justfile`, `package.json` scripts, `pyproject.toml`) before reporting success.

## Secrets posture

- Never print secrets to the terminal or write them to files.
- If a task needs a secret, request user intervention or pass via env var; do not persist.
- If you encounter what looks like a leaked secret in a file or diff, stop and flag it before continuing.
