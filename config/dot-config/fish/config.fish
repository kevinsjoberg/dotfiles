if status is-interactive
    set -gx EDITOR hx
end

# Initialize https://direnv.net
direnv hook fish | source

# Initialize http://asdf-vm.com
source ~/.asdf/asdf.fish
