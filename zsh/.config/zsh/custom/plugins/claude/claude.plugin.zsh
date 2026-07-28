# Wrapper around the `claude` CLI that always injects a few preferred flags.
#
# Configure by exporting any of these before the function is called:
#   CLAUDE_WRAPPER_SYSTEM_PROMPT_FILE  Path to a system prompt file. Passed via
#                                     --system-prompt-file when the file exists
#                                     and the user hasn't already supplied
#                                     --system-prompt or --system-prompt-file.
#                                     Default: $HOME/.claude/system-prompt.md
#   CLAUDE_WRAPPER_TOOLS              Space-separated list for --tools. Passed
#                                     when the user hasn't already supplied
#                                     --tools. Default: the tools listed in
#                                     SYSTEM.md's "Available tools" section.
#   CLAUDE_WRAPPER_EXTRA_ARGS         Array of additional default args to
#                                     prepend on every invocation.
#
# Bypass the wrapper for a single call with: `command claude ...`

function claude() {
  if (( ! $+commands[claude] )); then
    print -u2 "claude: command not found"
    return 127
  fi

  local -a prepend
  local has_system_prompt=0 has_tools=0 has_session=0 arg
  for arg in "$@"; do
    case "$arg" in
      --system-prompt|--system-prompt=*|--system-prompt-file|--system-prompt-file=*)
        has_system_prompt=1 ;;
      --tools|--tools=*)
        has_tools=1 ;;
      --session-id|--session-id=*|-r|--resume|--resume=*|-c|--continue|--from-pr|--from-pr=*)
        has_session=1 ;;
    esac
  done

  local session_id=""
  if (( ! has_session )); then
    session_id="$(uuidgen | tr '[:upper:]' '[:lower:]')"
    prepend+=(--session-id "$session_id")
  fi

  local prompt_file="${CLAUDE_WRAPPER_SYSTEM_PROMPT_FILE:="${functions_source[$0]:a:h}"/SYSTEM.md}"
  local rendered_prompt=""
  if (( ! has_system_prompt )) && [[ -r "$prompt_file" ]]; then
    rendered_prompt="$(mktemp -t claude-system-prompt)"
    _claude_render_system_prompt "$prompt_file" "$session_id" > "$rendered_prompt"
    prepend+=(--system-prompt-file "$rendered_prompt")
  fi

  # local tools="${CLAUDE_WRAPPER_TOOLS:=Read Bash Edit Write EnterWorktree ExitWorktree ScheduleWakeup Monitor}"
  # if (( ! has_tools )) && [[ -n "$tools" ]]; then
  #   prepend+=(--tools ${=tools})
  # fi

  if (( ${#CLAUDE_WRAPPER_EXTRA_ARGS[@]} )); then
    prepend+=("${CLAUDE_WRAPPER_EXTRA_ARGS[@]}")
  fi

  "${commands[claude]}" "${prepend[@]}" "$@"
  local ret=$?
  [[ -n "$rendered_prompt" ]] && rm -f "$rendered_prompt"
  return $ret
}

# Emits the system prompt file followed by an Environment section and a
# gitStatus snapshot, mirroring the dynamic sections of the default prompt.
function _claude_render_system_prompt() {
  local prompt_file="$1" session_id="$2"
  cat "$prompt_file"

  print
  print "# Environment"
  print "You have been invoked in the following environment:"
  print " - Primary working directory: $PWD"
  local in_repo=false
  git rev-parse --is-inside-work-tree &>/dev/null && in_repo=true
  print " - Is a git repository: $in_repo"
  print " - Platform: $(uname -s | tr '[:upper:]' '[:lower:]')"
  print " - OS Version: $(uname -sr)"
  print " - Shell: ${SHELL:t}"
  [[ -n "$session_id" ]] && print " - Session ID: $session_id"

  if [[ "$in_repo" == true ]]; then
    print
    print "gitStatus: This is the git status at the start of the conversation. Note that this status is a snapshot in time, and will not update during the conversation."
    print
    print "Current branch: $(git branch --show-current)"
    print
    print "Git user: $(git config user.name)"
    print
    print "Status:"
    local status_out="$(git status --short)"
    print "${status_out:-(clean)}"
    print
    print "Recent commits:"
    git log -5 --oneline --no-decorate 2>/dev/null
  fi
}
