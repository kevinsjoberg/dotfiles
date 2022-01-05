#!/usr/bin/env bash
set -eo pipefail

echo "Setting up dotfiles..."

function setup_homebrew() {
  if ! type brew > /dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  brew bundle
}

function setup_ssh() {
  local ssh_dir="$HOME/.ssh"

  if ! [[ -d "$ssh_dir" ]]; then
    mkdir -p "$ssh_dir" && chmod 700 "$ssh_dir"
  fi

  if ! type op > /dev/null 2>&1; then
    echo "1Password CLI missing. Installing it..."
    brew install --cask 1password-cli
  fi

  eval "$(op signin)"

  if ! op get account > /dev/null 2>&1; then
    echo "Not signed in to 1Password. Skipping..."
    return
  fi

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
}

function setup_macos() {
  if ! grep "$(which fish)" /etc/shells > /dev/null 2>&1; then
    which fish | sudo tee -a /etc/shells
    chsh -s "$(which fish)"
  fi

  stow --dotfiles --restow asdf
  stow --dotfiles --restow bash
  stow --dotfiles --restow bin
  stow --dotfiles --restow config
  stow --dotfiles --restow git
  stow --dotfiles --restow homebrew
  stow --dotfiles --restow tmux

  if ! [[ -d "$HOME/.asdf" ]]; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1
  fi

  source "$HOME/.asdf/asdf.sh"

  ! asdf plugin list | grep -q crystal && asdf plugin add crystal
  ! asdf plugin list | grep -q elm && asdf plugin add elm
  ! asdf plugin list | grep -q golang && asdf plugin add golang
  ! asdf plugin list | grep -q nodejs && asdf plugin add nodejs
  ! asdf plugin list | grep -q ruby && asdf plugin add ruby
  ! asdf plugin list | grep -q rust && asdf plugin add rust
  asdf install

  if ! [[ -d "$HOME/code" ]]; then
    mkdir "$HOME/code"
  fi

  if ! type hx > /dev/null 2>&1; then
    if ! [[ -d "$HOME/code/helix" ]]; then
      git clone --recurse-submodules --shallow-submodules -j8 git@github.com:helix-editor/helix.git "$HOME/code/helix"
    fi

    (cd "$HOME/code/helix" && cargo install --path helix-term)
  fi

  echo "$PWD"
}

setup_homebrew
setup_ssh
setup_macos