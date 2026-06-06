---
name: sync-upstream-skills
description: Sync vendored skills under agents/ from their upstream `source:` URLs, surfacing files the user has changed locally as conflicts to resolve. Use when the user wants to pull upstream changes into vendored skills, refresh skills from their sources, or reconcile local drift against upstream.
---

# sync-upstream-skills

Pulls the latest version of every skill under `agents/` whose `SKILL.md`
frontmatter has a `source:` URL. The mechanical work (cloning the source repo,
diffing, 3-way merge) is handled by `scripts/sync.sh`. Your job is the
conflict resolution.

## Run the script

```bash
.agents/skills/sync-upstream-skills/scripts/sync.sh           # default: apply non-conflicting changes, leave conflicts
.agents/skills/sync-upstream-skills/scripts/sync.sh --check   # report only, never write
.agents/skills/sync-upstream-skills/scripts/sync.sh grill-me  # restrict to one or more skill directories
```

A report is written to `${XDG_CACHE_HOME:-~/.cache}/dotfiles/sync-upstream-skills/report.md`
and echoed to stdout. Each per-skill section lists, per file:

- `+ path` — new file from upstream (copied in apply mode)
- `~ path  (merged cleanly)` — 3-way merge succeeded
- `! path  CONFLICT` — merge produced conflict markers, or no recorded base
  was available so user vs. upstream changes can't be told apart

## Resolving conflicts

For each `! CONFLICT` the report names, walk the user through this loop:

1. **Open the file.** When the script wrote conflict markers (3-way mode), the
   file has standard `<<<<<<<` / `=======` / `>>>>>>>` blocks. When the script
   couldn't run a 3-way merge (no `source-rev` recorded), the file is
   unchanged and the report shows both `upstream:` and `local:` paths — diff
   them yourself.

2. **Check for an ADR.** Look in `<repo root>/docs/adr/` for a decision that
   covers the conflicting passage.
   ```bash
   ls "$(git rev-parse --show-toplevel)/docs/adr/" 2>/dev/null
   ```
   ADR filenames are usually numbered and kebab-cased
   (e.g. `0007-keep-grill-me-recommendations-implicit.md`). Read any ADR that
   plausibly covers the conflicting topic.

3. **Apply the rule, per hunk:**
   - **No `docs/adr/` directory, or no ADR covers this hunk** → upstream wins.
     Take the upstream side.
   - **An ADR covers this hunk** → the ADR's decision wins for the passage it
     covers. Other hunks in the same file still default to upstream.

4. **Edit out the markers** so only the chosen content remains.

5. **After every conflict in a skill is resolved**, update that skill's
   `source-rev:` field in `SKILL.md` to the SHA the report names for it. That
   gives the next sync a clean 3-way base.

Show the user the resolution for each file before moving on — don't batch.

## Notes

- Only `https://github.com/<owner>/<repo>/tree/<branch>/<path>` source URLs are
  supported. The script skips and logs anything else.
- Files the user added inside a vendored skill directory with no upstream
  counterpart are left untouched (and not reported — they're not in conflict).
- `source-rev:` is added to the frontmatter automatically on the first clean
  sync of a skill. Until then, every file that differs from upstream is a
  conflict, since the script can't distinguish user edits from upstream drift.
- The script caches source clones at
  `${XDG_CACHE_HOME:-~/.cache}/dotfiles/sync-upstream-skills/`. Safe to delete.
