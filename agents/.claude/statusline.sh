#!/usr/bin/env bash
# Claude Code status line. Reads the session JSON payload on stdin.
set -uo pipefail

input=$(cat)

R=$'\033[0m'; B=$'\033[1m'; D=$'\033[2m'
BLUE=$'\033[34m'; CYAN=$'\033[36m'; YEL=$'\033[33m'
MAG=$'\033[35m'; GRN=$'\033[32m'; RED=$'\033[31m'

eval "$(printf '%s' "$input" | jq -r '
  @sh "cwd=\(.workspace.current_dir // .cwd // "")",
  @sh "model=\(.model.display_name // "?")",
  @sh "effort=\(.effort.level // "")",
  @sh "ctx_used=\(.context_window.total_input_tokens // 0)",
  @sh "ctx_max=\(.context_window.context_window_size // 0)",
  @sh "ctx_pct=\(.context_window.used_percentage // 0)",
  @sh "h5_pct=\(.rate_limits.five_hour.used_percentage // "")",
  @sh "h5_reset=\(.rate_limits.five_hour.resets_at // "")",
  @sh "d7_pct=\(.rate_limits.seven_day.used_percentage // "")",
  @sh "d7_reset=\(.rate_limits.seven_day.resets_at // "")"
')"

# Contract $HOME to ~ and keep the trailing 3 path components, as starship does.
shorten_path() {
  local p=${1/#$HOME/\~} keep=3 root="" seps
  [[ $p == /* ]] && { root=/; p=${p#/}; }
  seps=${p//[^\/]/}
  while (( ${#seps} >= keep )); do
    p=${p#*/}; seps=${seps#/}; root=""
  done
  printf '%s%s' "$root" "$p"
}

# branch + ahead/behind + staged/unstaged/untracked counts, from one porcelain call.
git_segment() {
  local out branch ab ahead behind staged unstaged untracked x y
  out=$(git -C "$cwd" status --porcelain=v2 --branch 2>/dev/null) || return
  staged=0; unstaged=0; untracked=0
  while IFS= read -r line; do
    case $line in
      '# branch.head '*) branch=${line#\# branch.head } ;;
      '# branch.ab '*)   ab=${line#\# branch.ab } ;;
      '?'*)              (( untracked++ )) ;;
      [12u]' '*)         x=${line:2:1}; y=${line:3:1}
                         [[ $x != . ]] && (( staged++ ))
                         [[ $y != . ]] && (( unstaged++ )) ;;
    esac
  done <<< "$out"
  [[ -z ${branch:-} || $branch == '(detached)' ]] && branch=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

  local flags=""
  (( staged ))    && flags+=" +$staged"
  (( unstaged ))  && flags+=" !$unstaged"
  (( untracked )) && flags+=" ?$untracked"
  if [[ -n ${ab:-} ]]; then
    ahead=${ab%% *}; behind=${ab##* }
    (( ${ahead#+} )) && flags+=" ↑${ahead#+}"
    (( ${behind#-} )) && flags+=" ↓${behind#-}"
  fi

  printf '%s' " ${B}${CYAN}${branch}${R}"
  [[ -n $flags ]] && printf '%s' "${B}${YEL}${flags}${R}"
}

# 45231 -> 45.2k, 200000 -> 200k
tokens() {
  awk -v n="$1" 'BEGIN{
    if (n >= 1000000) { v=n/1000000; printf (v==int(v) ? "%dM" : "%.1fM"), v }
    else if (n >= 1000) { v=n/1000; printf (v==int(v) ? "%dk" : "%.1fk"), v }
    else printf "%d", n
  }'
}

# green under 60%, yellow under 85%, red above.
pct_color() {
  local p=${1%%.*}
  if   (( p >= 85 )); then printf '%s' "$RED"
  elif (( p >= 60 )); then printf '%s' "$YEL"
  else                     printf '%s' "$GRN"; fi
}

# resets_at is epoch seconds; fall back to parsing an ISO-8601 string.
reset_time() {
  local v=$1 epoch
  [[ -z $v || $v == null ]] && return
  if [[ $v =~ ^[0-9]+$ ]]; then
    epoch=$v
  else
    epoch=$(date -j -f '%Y-%m-%dT%H:%M:%S' "${v%%.*}" +%s 2>/dev/null) || return
  fi
  if [[ $(date -r "$epoch" +%F 2>/dev/null) == "$(date +%F)" ]]; then
    date -r "$epoch" '+%-I:%M %p %Z' 2>/dev/null
  else
    date -r "$epoch" '+%a %-I:%M %p %Z' 2>/dev/null
  fi
}

limit_segment() {
  local label=$1 pct=$2 raw=$3 when
  [[ -z $pct || $pct == null ]] && return
  pct=${pct%%.*}
  printf '%s' " ${D}·${R} ${D}${label}${R} $(pct_color "$pct")${pct}%${R}"
  when=$(reset_time "$raw")
  [[ -n $when ]] && printf '%s' " ${D}resets ${when}${R}"
}

line1="${B}${BLUE}$(shorten_path "$cwd")${R}$(git_segment)"

line2="${MAG}${model}${R}"
[[ -n $effort ]] && line2+=" ${D}${effort}${R}"
line2+=" ${D}·${R} ${D}ctx${R} $(tokens "$ctx_used")${D}/${R}$(tokens "$ctx_max")"
line2+=" $(pct_color "$ctx_pct")(${ctx_pct}%)${R}"
line2+=$(limit_segment 5h "$h5_pct" "$h5_reset")
line2+=$(limit_segment 7d "$d7_pct" "$d7_reset")

printf '%b\n%b\n' "$line1" "$line2"
