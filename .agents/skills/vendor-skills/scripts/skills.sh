#!/usr/bin/env bash
#
# Vendor skills into the `agents` stow package via the skills.sh CLI (npx skills).
# Source of truth is skills.txt: one "<owner/repo> <skill-name>" per line.
#
# The CLI has no lockfile and no custom-output-dir flag, so this wrapper owns
# placement: it fetches each skill into a temp dir with `--copy`, then syncs the
# result into agents/.agents/skills/<name>/. Skills float to upstream latest.
#
# Skills marked `metadata: internal: true` (e.g. deploy-fleet-app) are private
# and hand-managed: never fetched by `update`, never deleted by `prune`.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
manifest="$here/../skills.txt"
repo_root="$(git -C "$here" rev-parse --show-toplevel)"
dest="$repo_root/agents/.agents/skills"

usage() {
  cat <<'EOF'
Usage: skills.sh <command> [args]

  add <owner/repo> <skill>   Vendor a skill and record it in skills.txt
  update [skill...]          Re-fetch tracked skills (all, or just the named ones)
  remove <skill>             Delete a vendored skill and drop its skills.txt entry
  prune                      Delete vendored skills not tracked in skills.txt (keeps internal ones)
  list                       Print tracked skills

After add/update/remove/prune the agents package is re-stowed automatically.
EOF
}

# Emit tracked skill names (column 2), skipping blanks and comments.
tracked_names() { awk 'NF && $1 !~ /^#/ { print $2 }' "$manifest"; }

# Print the owner/repo recorded for a skill name, or nothing.
repo_for() { awk -v n="$1" 'NF && $1 !~ /^#/ && $2==n { print $1; exit }' "$manifest"; }

# True when a vendored skill's frontmatter marks it internal (hand-managed).
is_internal() {
  local f="$dest/$1/SKILL.md"
  [ -f "$f" ] || return 1
  awk '
    /^---[[:space:]]*$/ { n++; next }
    n==1 && /^[[:space:]]*internal:[[:space:]]*true[[:space:]]*$/ { found=1 }
    n>=2 { exit }
    END { exit found ? 0 : 1 }
  ' "$f"
}

# Fetch one skill from upstream into the vendored tree, replacing it wholesale.
fetch() {
  local repo="$1" name="$2" tmp
  tmp="$(mktemp -d)"
  ( cd "$tmp" && npx --yes skills@latest add "$repo" --skill "$name" --copy -y -a claude-code >/dev/null 2>&1 )
  if [ ! -d "$tmp/.claude/skills/$name" ]; then
    rm -rf "$tmp"
    echo "error: skill '$name' not found in $repo" >&2
    return 1
  fi
  mkdir -p "$dest/$name"
  rsync -a --delete "$tmp/.claude/skills/$name/" "$dest/$name/"
  rm -rf "$tmp"
  echo "vendored $name  <- $repo"
}

restow() { stow -R -t "$HOME" -d "$repo_root" agents; }

cmd="${1:-}"
[ "$#" -gt 0 ] && shift || true

case "$cmd" in
  add)
    repo="${1:?owner/repo required}"; name="${2:?skill name required}"
    if ! tracked_names | grep -qxF "$name"; then
      printf '%s %s\n' "$repo" "$name" >> "$manifest"
    fi
    fetch "$repo" "$name"
    restow
    ;;

  update)
    if [ "$#" -gt 0 ]; then names="$*"; else names="$(tracked_names)"; fi
    for name in $names; do
      if is_internal "$name"; then echo "skip $name (internal)"; continue; fi
      repo="$(repo_for "$name")"
      if [ -z "$repo" ]; then echo "skip $name (not in skills.txt)"; continue; fi
      fetch "$repo" "$name"
    done
    restow
    ;;

  remove)
    name="${1:?skill name required}"
    tmpf="$(mktemp)"
    awk -v n="$name" 'NF && $1 !~ /^#/ && $2==n { next } { print }' "$manifest" > "$tmpf"
    mv "$tmpf" "$manifest"
    rm -rf "${dest:?}/$name"
    echo "removed $name"
    restow
    ;;

  prune)
    for d in "$dest"/*/; do
      name="$(basename "$d")"
      if tracked_names | grep -qxF "$name"; then continue; fi
      if is_internal "$name"; then echo "keep $name (internal)"; continue; fi
      rm -rf "$d"
      echo "pruned $name"
    done
    restow
    ;;

  list)
    awk 'NF && $1 !~ /^#/ { printf "%-32s %s\n", $2, $1 }' "$manifest"
    ;;

  ""|-h|--help|help) usage ;;
  *) echo "unknown command: $cmd" >&2; usage; exit 1 ;;
esac
