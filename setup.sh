#!/usr/bin/env bash
set -euo pipefail

# PATHS
if [ -n "${BASH_SOURCE[0]-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  SCRIPT_DIR="$(pwd)"
fi
DOTFILES_DIR="$SCRIPT_DIR"
TARGET_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

echo "==> Starting Configuration..."


# SYMLINKS
mkdir -p "$HOME/.local/bin"

if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
  echo "    Linking batcat -> bat"
  ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
fi

if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  echo "    Linking fdfind -> fd"
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

# PATH
export PATH="$HOME/.local/bin:$PATH"

export TERM="xterm-256color"


# SHELL
echo "==> Configuring Bash"

# Container-only alias to update nvim from this repo
IS_CONTAINER=0
if [ "${DEVPOD:-}" = "true" ]; then
  IS_CONTAINER=1
elif [ -f /.dockerenv ]; then
  IS_CONTAINER=1
elif grep -qaE 'container=|docker|podman|lxc|kubepods' /proc/1/environ 2>/dev/null; then
  IS_CONTAINER=1
fi

if [ "$IS_CONTAINER" -eq 1 ]; then
  echo "==> Adding config update alias"
  CONFIG_UPDATE_ALIAS="alias config-update='(cd \"$DOTFILES_DIR\" && git pull --ff-only && _CONFIG_HOME=\"\${XDG_CONFIG_HOME:-\$HOME/.config}\" && mkdir -p \"\$_CONFIG_HOME\" && cp -a \"$DOTFILES_DIR/.config/.\" \"\$_CONFIG_HOME/\")'"
  touch "$HOME/.bashrc"
  if grep -q "alias config-update=" "$HOME/.bashrc"; then
    sed -i '/^alias config-update=/d' "$HOME/.bashrc"
  fi
  printf "\n# Update dotfiles .config from repo\n%s\n" "$CONFIG_UPDATE_ALIAS" >>"$HOME/.bashrc"
fi

# Config
if [ -d "$DOTFILES_DIR/.config" ]; then
  echo "==> Merging dotfiles .config"
  mkdir -p "$TARGET_CONFIG_DIR"
  cp -a "$DOTFILES_DIR/.config/." "$TARGET_CONFIG_DIR/"
fi

# COPILOT LANGUAGE SERVER
if command -v npm >/dev/null 2>&1; then
  echo "==> Installing Copilot Language Server"
  npm config set prefix "$HOME/.local" >/dev/null 2>&1 || true
  if ! npm install -g @github/copilot-language-server; then
    echo "==> Copilot Language Server install failed; continuing" >&2
  fi
fi

echo "==> Setup Complete!"
