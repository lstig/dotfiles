if [[ -d "$HOME/.orbstack/bin" ]]; then
  export PATH="$PATH:$HOME/.orbstack/bin"
  fpath+="/Applications/OrbStack.app/Contents/Resources/completions/zsh"
fi
