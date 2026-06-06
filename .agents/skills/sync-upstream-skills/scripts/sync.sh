#!/usr/bin/env bash
# sync.sh — refresh vendored skills under agents/ from their upstream `source:` URLs.
#
# For every SKILL.md whose frontmatter has a `source:` URL pointing at a
# github.com/<owner>/<repo>/tree/<branch>/<path> location, this script:
#
#   1. Clones (or fast-forwards) the source repo into a cache directory.
#   2. For each file present in the upstream tree:
#        - missing locally       → copy from upstream (reported as `+`)
#        - identical             → no-op
#        - differs, with a base  → run `git merge-file` (3-way merge)
#        - differs, no base      → mark CONFLICT for manual review
#   3. On a clean sync (no conflicts), updates `source-rev:` in the
#      skill's SKILL.md frontmatter so the next run has a real merge base.
#
# Files the user added locally inside a vendored skill (no upstream
# counterpart) are left untouched.

set -euo pipefail

if ! command -v yq >/dev/null 2>&1; then
  echo "sync.sh: requires yq (https://github.com/mikefarah/yq)" >&2
  exit 1
fi

DOTFILES="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$DOTFILES" || ! -d "$DOTFILES/agents" ]]; then
  echo "sync.sh: must be run inside the dotfiles repo (no agents/ found)" >&2
  exit 1
fi

AGENTS_DIR="$DOTFILES/agents"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/sync-upstream-skills"
REPORT="$CACHE_DIR/report.md"
mkdir -p "$CACHE_DIR"

TMP_DIR="$(mktemp -d "$CACHE_DIR/run.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

MODE="apply"   # apply | check
TARGETS=()

usage() {
  cat <<EOF
Usage: $(basename "$0") [--check|--apply] [SKILL_NAME...]

  --apply    Apply non-conflicting upstream changes (default).
  --check    Report only — do not modify any local files.

If SKILL_NAME args are given, only skills whose directory basename matches
are processed.

Output report: $REPORT
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) MODE="apply"; shift ;;
    --check) MODE="check"; shift ;;
    -h|--help) usage; exit 0 ;;
    --*) echo "unknown flag: $1" >&2; usage; exit 2 ;;
    *) TARGETS+=("$1"); shift ;;
  esac
done

: > "$REPORT"

log()    { printf '%s\n' "$*"; }
report() { printf '%s\n' "$*" >> "$REPORT"; }
both()   { log "$*"; report "$*"; }

# Pull a top-level scalar out of YAML frontmatter. Empty string if missing.
fm_field() {
  # fm_field FILE KEY
  KEY="$2" yq --front-matter=extract '.[strenv(KEY)] // ""' "$1"
}

# https://github.com/OWNER/REPO/tree/BRANCH/PATH → "OWNER REPO BRANCH PATH"
# Returns non-zero on a URL we don't support.
parse_gh_tree_url() {
  local url="$1"
  if [[ "$url" =~ ^https://github\.com/([^/]+)/([^/]+)/tree/([^/]+)/(.+)$ ]]; then
    printf '%s\n%s\n%s\n%s\n' \
      "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" \
      "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}"
    return 0
  fi
  return 1
}

# Clone or fast-forward the source repo into the cache. Echoes its path.
ensure_repo() {
  local owner="$1" repo="$2" branch="$3"
  local dir="$CACHE_DIR/repos/$owner-$repo"
  if [[ -d "$dir/.git" ]]; then
    git -C "$dir" fetch --quiet origin "$branch"
    git -C "$dir" checkout --quiet "$branch" 2>/dev/null || git -C "$dir" checkout --quiet -B "$branch" "origin/$branch"
    git -C "$dir" reset --hard --quiet "origin/$branch"
  else
    mkdir -p "$(dirname "$dir")"
    git clone --quiet --branch "$branch" --single-branch \
      "https://github.com/$owner/$repo.git" "$dir"
  fi
  printf '%s\n' "$dir"
}

# Rewrite the `source-rev:` line in a SKILL.md's frontmatter (insert if absent).
update_source_rev() {
  # update_source_rev FILE SHA
  SHA="$2" yq --front-matter=process -i '.["source-rev"] = strenv(SHA)' "$1"
}

CONFLICTS=0
UPDATED=0
ADDED=0
MERGED=0
SKIPPED=0

process_skill() {
  local skill_md="$1"
  local skill_dir; skill_dir="$(dirname "$skill_md")"
  local skill_name; skill_name="$(basename "$skill_dir")"

  local source_url base_rev
  source_url="$(fm_field "$skill_md" source)"
  [[ -z "$source_url" ]] && return 0
  base_rev="$(fm_field "$skill_md" source-rev)"

  if (( ${#TARGETS[@]} > 0 )); then
    local match=0 t
    for t in "${TARGETS[@]}"; do [[ "$t" == "$skill_name" ]] && { match=1; break; }; done
    (( match )) || return 0
  fi

  both ""
  both "## $skill_name"
  both "- source:  $source_url"
  both "- local:   ${skill_dir#$DOTFILES/}"

  local owner repo branch path
  if ! { read -r owner; read -r repo; read -r branch; read -r path; } < <(parse_gh_tree_url "$source_url"); then
    both "- ! unsupported source URL — only github.com tree URLs are supported"
    SKIPPED=$(( SKIPPED + 1 ))
    return 0
  fi

  local repo_dir upstream_dir upstream_rev
  repo_dir="$(ensure_repo "$owner" "$repo" "$branch")"
  upstream_rev="$(git -C "$repo_dir" rev-parse HEAD)"
  upstream_dir="$repo_dir/$path"
  both "- upstream rev: \`$upstream_rev\`"
  [[ -n "$base_rev" ]] && both "- recorded base: \`$base_rev\`" \
                       || both "- recorded base: (none — first sync; all diffs are conflicts)"

  if [[ ! -d "$upstream_dir" ]]; then
    both "- ! upstream path no longer exists: $path"
    SKIPPED=$(( SKIPPED + 1 ))
    return 0
  fi

  if [[ -n "$base_rev" && "$base_rev" == "$upstream_rev" ]]; then
    both "- ✓ already up to date"
    return 0
  fi

  local conflicts_here=0 added_here=0 merged_here=0 changed_here=0
  local upstream_file rel local_file base_file merged

  while IFS= read -r -d '' upstream_file; do
    rel="${upstream_file#$upstream_dir/}"
    local_file="$skill_dir/$rel"

    if [[ ! -e "$local_file" ]]; then
      both "  + $rel  (new from upstream)"
      added_here=$(( added_here + 1 ))
      if [[ "$MODE" == "apply" ]]; then
        mkdir -p "$(dirname "$local_file")"
        cp "$upstream_file" "$local_file"
      fi
      continue
    fi

    if cmp -s "$upstream_file" "$local_file"; then
      continue
    fi

    if [[ -n "$base_rev" ]]; then
      base_file="$(mktemp "$TMP_DIR/base.XXXXXX")"
      if git -C "$repo_dir" show "$base_rev:$path/$rel" > "$base_file" 2>/dev/null; then
        merged="$(mktemp "$TMP_DIR/merged.XXXXXX")"
        if git merge-file -p -L local -L base -L upstream \
             "$local_file" "$base_file" "$upstream_file" > "$merged" 2>/dev/null; then
          both "  ~ $rel  (merged cleanly)"
          merged_here=$(( merged_here + 1 ))
          [[ "$MODE" == "apply" ]] && cp "$merged" "$local_file"
        else
          both "  ! $rel  CONFLICT — merge produced conflict markers"
          conflicts_here=$(( conflicts_here + 1 ))
          if [[ "$MODE" == "apply" ]]; then
            cp "$merged" "$local_file"
            both "      written with markers; resolve in: ${local_file#$DOTFILES/}"
          else
            both "      upstream: $upstream_file"
            both "      local:    ${local_file#$DOTFILES/}"
          fi
        fi
        continue
      fi
      # Base didn't have this file — treat as a no-base conflict.
    fi

    both "  ! $rel  CONFLICT — no recorded base, manual review required"
    both "      upstream: $upstream_file"
    both "      local:    ${local_file#$DOTFILES/}"
    conflicts_here=$(( conflicts_here + 1 ))
  done < <(find "$upstream_dir" -type f -print0)

  changed_here=$(( added_here + merged_here + conflicts_here ))

  if (( changed_here == 0 )); then
    both "- ✓ no changes; bumping recorded base to current upstream"
    if [[ "$MODE" == "apply" && "$base_rev" != "$upstream_rev" ]]; then
      update_source_rev "$skill_md" "$upstream_rev"
    fi
    return 0
  fi

  if (( conflicts_here > 0 )); then
    both "- ! $conflicts_here file conflict(s); resolve them, then set source-rev: $upstream_rev"
    CONFLICTS=$(( CONFLICTS + conflicts_here ))
  else
    both "- ✓ clean sync ($merged_here merged, $added_here added)"
    if [[ "$MODE" == "apply" ]]; then
      update_source_rev "$skill_md" "$upstream_rev"
      UPDATED=$(( UPDATED + 1 ))
    fi
  fi
  ADDED=$(( ADDED + added_here ))
  MERGED=$(( MERGED + merged_here ))
}

while IFS= read -r -d '' f; do
  process_skill "$f"
done < <(find "$AGENTS_DIR" -type f -name 'SKILL.md' -print0)

both ""
both "## Summary"
both "- mode: $MODE"
both "- skills updated cleanly: $UPDATED"
both "- files merged: $MERGED, added: $ADDED"
both "- file conflicts: $CONFLICTS"
both "- skills skipped: $SKIPPED"
both ""
both "Report: $REPORT"

(( CONFLICTS == 0 ))
