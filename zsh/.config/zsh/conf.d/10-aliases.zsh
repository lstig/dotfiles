# Custom aliases
alias ls='ls -laGFh'
alias vim='nvim'

# System utility aliases
alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'
alias resetLaunchPad='defaults write com.apple.dock ResetLaunchPad -bool true; killall Dock'

# ignore zsh square brackets for pip - avoids needing to escape them like '\['
alias pip="noglob pip"
alias pip3="noglob pip3"
alias tofu="noglob tofu"
alias jq="noglob jq"
alias yq="noglob yq"

# Misc
alias mp3-dl="yt-dlp -o \"%(title)s.%(ext)s\" -x --audio-format mp3"
