#!/usr/bin/env bash
set -eo pipefail

echo "Setting up dotfiles..."

function setup_homebrew() {
  if ! type brew > /dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  brew bundle
}



function setup_macos() {
  stow --dotfiles --restow asdf
  stow --dotfiles --restow bash
  stow --dotfiles --restow bin
  stow --dotfiles --restow config
  stow --dotfiles --restow git
  stow --dotfiles --restow homebrew
  stow --dotfiles --restow tmux

  # TODO: Setup shell
  if ! grep $(which fish) /etc/shells > /dev/null 2>&1; then
    echo $(which fish) | sudo tee -a /etc/shells
  fi

  # TODO: Setup asdf
  asdf plugin add crystal
  asdf plugin add elm
  asdf plugin add golang
  asdf plugin add nodejs
  asdf plugin add ruby
  asdf plugin add rust
  asdf install
}

function setup_ssh() {
  local ssh_dir="$HOME/.ssh"

  if [[ -d "$ssh_dir" ]]; then
    return
  fi

  if ! type op > /dev/null 2>&1; then
    echo "1Password CLI missing. Installing it..."
    brew install --cask 1password-cli
  fi

  mkdir -p "$ssh_dir" && chmod 700 "$ssh_dir"

  eval "$(op signin)"

  local doc
  local doc_name
  local doc_permissions
  for doc_id in $(op list items | jq '.[] | select(.overview.title=="SSH - id_rsa")' | op get item - | jq -r '.details.sections[].fields[] | select(.k=="reference") | .v'); do
    doc=$(op get item "$doc_id")
    doc_name=$(jq -r '.overview.title' <<< "$doc")
    doc_permissions=$(jq -r '.details.sections[] | select(has("fields")) | .fields[] | select(.t=="permissions") | .v' <<< "$doc")

    op get document "$doc_id" --output "$ssh_dir/$doc_name"
    chmod "$doc_permissions" "$ssh_dir/$doc_name"
  done

  # TODO: Change the dotfiles remote to SSH instead of HTTPS here
}

setup_homebrew
setup_macos
setup_ssh