export TERM="xterm-256color"
export ZSH="$HOME/.local/ohmyzsh"

if [[ ! -d "$ZSH" ]]; then
  echo "oh-my-zsh not found at $ZSH — installing…"
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH"
  # Run the installer in unattended mode so it doesn't overwrite this .zshrc
  ZSH="$ZSH" sh "$ZSH/tools/install.sh" --keep-zshrc --unattended
fi

# path setup
export GOBIN="$HOME/.local/bin" # set the go bin directory to something sane
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/make/libexec/gnubin:$PATH"
export PATH="$HOMEBREW_PREFIX/opt/llvm/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# zsh configuration
ZSH_CUSTOM="$ZDOTDIR/custom"
ZSH_COMPDUMP="$HOME/.cache/zsh/.zcompdump"
HISTFILE="$HOME/.zsh_history"
HISTORY_IGNORE='(^yt-dl)'

# load oh-my-zsh
plugins=(media-tools direnv claude)
source $ZSH/oh-my-zsh.sh

# oh-my-zsh's lib/history.zsh turns on SHARE_HISTORY, which makes every
# prompt read-merge-write $HISTFILE against all other live sessions. With
# multiple concurrent shells this is a well-known source of corrupted/
# truncated histfiles. Atuin records history independently (see 40-atuin.zsh)
# so we don't need cross-session live sharing here — just append each
# session's own lines on command exit.
unsetopt share_history
setopt inc_append_history

# Treat the ‘#’, ‘~’ and ‘^’ characters as part of patterns for filename
# generation, etc. (An initial unquoted ‘~’ always produces named directory
# expansion.)
setopt extended_glob

# load drop-in configs
for config in $ZDOTDIR/conf.d/*.zsh; do
  source "$config"
done
