# Keybindings.
[[ -o interactive ]] || return 0

bindkey -v

if [[ -o zle ]] && command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh) 2>/dev/null
fi

# Copy last command to clipboard.
copy-last-cmd() {
  local last_command
  last_command="$(fc -ln -1 | sed 's/^[[:space:]]*//')"
  print -rn -- "$last_command" | pbcopy
  zle -M "Copied: $last_command"
}

zle -N copy-last-cmd
bindkey '^[c' copy-last-cmd
