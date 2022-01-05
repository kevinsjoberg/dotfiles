# Prevent output redirection using ‘>’, ‘>&’, and ‘<>’ from overwriting
# existing files.
set -o noclobber

# Minor errors in the spelling of a directory component in a cd command will be
# corrected.
shopt -s cdspell

# Bash attempts spelling correction on directory names during word completion
# if the directory name initially supplied does not exist.
shopt -s dirspell

# The pattern ‘**’ used in a filename expansion context will match all files
# and zero or more directories and subdirectories. If the pattern is followed
# by a ‘/’, only directories and subdirectories match.
shopt -s globstar

# Bash matches filenames in a case-insensitive fashion when performing filename
# expansion.
shopt -s nocaseglob

# The history list is appended to the file named by the value of the HISTFILE
# variable when the shell exits, rather than overwriting the file.
shopt -s histappend

# See https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html.
HISTCONTROL="erasedups:ignoreboth"
HISTTIMEFORMAT="%F %T "

# If set to a number greater than zero, the value is used as the number of
# trailing directory components to retain when expanding the \w and \W prompt
# string escapes.
PROMPT_DIRTRIM=2

# Specify a proper locale.
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# Use TextMate as the interactive editor.
export EDITOR="mate -w"

# Enable colors for the ls-command.
export CLICOLOR=1

# Add $HOME/bin to PATH.
export PATH="$HOME/bin:$PATH"

# Set prompt.
PS1="\w\$(__git_ps1) \\$ "

# Let pkg-config find openssl@1.1
if [ -d "$(brew --prefix openssl@1.1 || true)" ]; then
  export PKG_CONFIG_PATH="/usr/local/opt/openssl@1.1/lib/pkgconfig"
fi

# Enable bash completion.
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

# Enable direnv.
if type direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"

  if type tmux >/dev/null 2>&1; then
    alias tmux='direnv exec / tmux'
  fi
fi

# Enable asdf.
if [[ -d "$HOME/.asdf" ]]; then
  . $HOME/.asdf/asdf.sh
  . $HOME/.asdf/completions/asdf.bash
fi

# Enable fzf.
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Enable nnn plugins.
export NNN_PLUG='o:fzopen'
