if (( ! $+commands[pnpm] )); then
  echo "Warning: pnpm not found. Please install pnpm and ensure it's in your PATH."
  return
fi
export PNPM_HOME="$HOME/.local/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
