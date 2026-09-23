# Antidote plugin manager (load after compinit for compdef).
# Bundle conditionals from .zsh_plugins.txt.
has-fzf() { (( $+commands[fzf] )) }

if [[ -r "$HOME/.antidote/antidote.zsh" ]]; then
  source "$HOME/.antidote/antidote.zsh"
  antidote load "$HOME/.zsh_plugins.txt"
elif command -v brew >/dev/null 2>&1; then
  antidote_path="$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh"
  if [[ -r "$antidote_path" ]]; then
    source "$antidote_path"
    antidote load "$HOME/.zsh_plugins.txt"
  fi
  unset antidote_path
fi
