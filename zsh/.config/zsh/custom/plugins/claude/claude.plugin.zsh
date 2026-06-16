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
  local has_system_prompt=0 has_tools=0 arg
  for arg in "$@"; do
    case "$arg" in
      --system-prompt|--system-prompt=*|--system-prompt-file|--system-prompt-file=*)
        has_system_prompt=1 ;;
      --tools|--tools=*)
        has_tools=1 ;;
    esac
  done

  local prompt_file="${CLAUDE_WRAPPER_SYSTEM_PROMPT_FILE:="${functions_source[$0]:a:h}"/SYSTEM.md}"
  if (( ! has_system_prompt )) && [[ -r "$prompt_file" ]]; then
    prepend+=(--system-prompt-file "$prompt_file")
  fi

  # local tools="${CLAUDE_WRAPPER_TOOLS:=Read Bash Edit Write EnterWorktree ExitWorktree ScheduleWakeup Monitor}"
  # if (( ! has_tools )) && [[ -n "$tools" ]]; then
  #   prepend+=(--tools ${=tools})
  # fi

  if (( ${#CLAUDE_WRAPPER_EXTRA_ARGS[@]} )); then
    prepend+=("${CLAUDE_WRAPPER_EXTRA_ARGS[@]}")
  fi

  "${commands[claude]}" "${prepend[@]}" "$@"
}
