# ~/.zshenv

export ZDOTDIR="$HOME/.config/zsh"

# initialize brew if the command exists
if [[ -x /opt/homebrew/bin/brew ]]; then
  # Explicitly adding the output of 'brew shellenv' so we don't have to
  # arbitrarily 'eval' the output which may not be trusted or change overtime.
  export HOMEBREW_PREFIX="/opt/homebrew";
  export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
  export HOMEBREW_REPOSITORY="/opt/homebrew";
  fpath[1,0]="/opt/homebrew/share/zsh/site-functions";
  export FPATH;
  # path_helper is the deliberate exception to the no-eval policy (see ADR
  # 0003): its output depends on /etc/paths.d, which installers add to over
  # time, so it can't be frozen like the rest of this block.
  eval "$(/usr/bin/env PATH_HELPER_ROOT="/opt/homebrew" /usr/libexec/path_helper -s)"
  [ -z "${MANPATH-}" ] || export MANPATH=":${MANPATH#:}";
  export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";
fi
