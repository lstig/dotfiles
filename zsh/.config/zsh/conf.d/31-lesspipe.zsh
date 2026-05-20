if (( ! $+commands[lesspipe.sh] )); then
  echo "Warning: lesspipe.sh not found. Please install lesspipe.sh and ensure it's in your PATH."
  return
fi
export LESSOPEN="|$commands[lesspipe.sh] %s"
export LESS_ADVANCED_PREPROCESSOR=1
