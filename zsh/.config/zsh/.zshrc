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
plugins=(media-tools direnv)
source $ZSH/oh-my-zsh.sh
setopt extendedglob

# load drop-in configs
for config in $ZDOTDIR/conf.d/*.zsh; do
  source "$config"
done
