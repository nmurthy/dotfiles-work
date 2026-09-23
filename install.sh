#!/bin/sh
# Coder dotfiles entrypoint: apply this repo with chezmoi (work profile by default).
set -eu

src=$(cd "$(dirname "$0")" && pwd)
DOTFILES_PROFILE=${DOTFILES_PROFILE:-work}
export DOTFILES_PROFILE

bin="$HOME/.local/bin"
if command -v chezmoi >/dev/null 2>&1; then
  chezmoi=$(command -v chezmoi)
elif [ -x "$bin/chezmoi" ]; then
  chezmoi="$bin/chezmoi"
else
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$bin"
  chezmoi="$bin/chezmoi"
fi

[ -d "$HOME/.antidote" ] || git clone -q --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.antidote"

# Coder reruns this on every start without a TTY; --force lets the source win.
exec "$chezmoi" init --apply --force --exclude=encrypted --source "$src"
