if status is-interactive
    set -gx EDITOR hx

    if test -d "/opt/homebrew"
        eval (/opt/homebrew/bin/brew shellenv)
    end
end

# Initialize https://direnv.net
direnv hook fish | source

# Initialize http://asdf-vm.com
source ~/.asdf/asdf.fish
