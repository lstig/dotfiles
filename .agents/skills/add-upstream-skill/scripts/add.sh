#!/usr/bin/env bash
# add.sh — vendor a new upstream skill into agents/.claude/skills/.
#
# Takes a single argument: the upstream skill's GitHub tree URL, e.g.
#   https://github.com/<owner>/<repo>/tree/<branch>/<path-to-skill-dir>
#
# Copies the skill directory into agents/.claude/skills/<basename>/ and
# rewrites SKILL.md frontmatter so sync-upstream-skills can track it:
#   - name:           the skill's directory basename (if unset upstream)
#   - source:         the input URL
#   - source-rev:     upstream HEAD SHA
#   - source-author:  owner's GitHub display name (falls back to login)

set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <github-tree-url>

Example:
  $(basename "$0") https://github.com/mattpocock/skills/tree/main/skills/productivity/handoff
EOF
}

if [[ $# -ne 1 ]]; then
  usage >&2
  exit 2
fi

URL="$1"

if ! command -v yq >/dev/null 2>&1; then
  echo "add.sh: requires yq (https://github.com/mikefarah/yq)" >&2
  exit 1
fi

DOTFILES="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$DOTFILES" || ! -d "$DOTFILES/agents" ]]; then
  echo "add.sh: must be run inside the dotfiles repo (no agents/ found)" >&2
  exit 1
fi

if [[ ! "$URL" =~ ^https://github\.com/([^/]+)/([^/]+)/tree/([^/]+)/(.+)$ ]]; then
  echo "add.sh: only github.com tree URLs are supported" >&2
  echo "        expected: https://github.com/<owner>/<repo>/tree/<branch>/<path>" >&2
  exit 1
fi
OWNER="${BASH_REMATCH[1]}"
REPO="${BASH_REMATCH[2]}"
BRANCH="${BASH_REMATCH[3]}"
SUBPATH="${BASH_REMATCH[4]}"

SKILL_NAME="$(basename "$SUBPATH")"
DEST="$DOTFILES/agents/.claude/skills/$SKILL_NAME"

if [[ -e "$DEST" ]]; then
  echo "add.sh: $DEST already exists — remove it first to re-vendor" >&2
  exit 1
fi

# Share the cache directory with sync-upstream-skills so a clone is reused.
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/sync-upstream-skills"
REPO_DIR="$CACHE_DIR/repos/$OWNER-$REPO"
mkdir -p "$CACHE_DIR/repos"

if [[ -d "$REPO_DIR/.git" ]]; then
  git -C "$REPO_DIR" fetch --quiet origin "$BRANCH"
  git -C "$REPO_DIR" checkout --quiet "$BRANCH" 2>/dev/null \
    || git -C "$REPO_DIR" checkout --quiet -B "$BRANCH" "origin/$BRANCH"
  git -C "$REPO_DIR" reset --hard --quiet "origin/$BRANCH"
else
  git clone --quiet --branch "$BRANCH" --single-branch \
    "https://github.com/$OWNER/$REPO.git" "$REPO_DIR"
fi

SRC="$REPO_DIR/$SUBPATH"
if [[ ! -d "$SRC" ]]; then
  echo "add.sh: $SUBPATH not found in $OWNER/$REPO" >&2
  exit 1
fi
if [[ ! -f "$SRC/SKILL.md" ]]; then
  echo "add.sh: $SUBPATH does not contain SKILL.md" >&2
  exit 1
fi

REV="$(git -C "$REPO_DIR" rev-parse HEAD)"

# Look up the owner's display name; fall back to the login.
AUTHOR="$OWNER"
if command -v gh >/dev/null 2>&1; then
  name="$(gh api "users/$OWNER" --jq '.name' 2>/dev/null || true)"
  if [[ -n "$name" && "$name" != "null" ]]; then
    AUTHOR="$name"
  fi
fi

mkdir -p "$DEST"
cp -R "$SRC"/. "$DEST"/

SKILL_MD="$DEST/SKILL.md"

# Rewrite frontmatter:
#   - ensure `name` exists (default to the directory basename)
#   - set source / source-rev / source-author
SKILL_NAME_VAL="$SKILL_NAME" URL_VAL="$URL" REV_VAL="$REV" AUTHOR_VAL="$AUTHOR" \
yq --front-matter=process -i '
  .name = (.name // strenv(SKILL_NAME_VAL)) |
  .source = strenv(URL_VAL) |
  .["source-rev"] = strenv(REV_VAL) |
  .["source-author"] = strenv(AUTHOR_VAL)
' "$SKILL_MD"

cat <<EOF
✓ added $SKILL_NAME
  path:          agents/.claude/skills/$SKILL_NAME
  source:        $URL
  source-rev:    $REV
  source-author: $AUTHOR

Next:
  stow -v -R -t "\$HOME" -d "$DOTFILES" agents
EOF
