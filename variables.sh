export MANPAGER='nvim -c "set ft=man" -'
export EDITOR=nvim
export LESS=-iR
export TEXMFHOME=$HOME/.texmf
export MPD_HOST=/$HOME/.mpd/socket
export TERM=rxvt-256color
export CHROME_BIN="$(which chromium)"

export PATH="${PATH}:$HOME/.local/bin"
export PATH="${PATH}:$HOME/.cargo/bin"

# Set LS_COLORS variable
eval $(dircolors $HOME/.dir_colors 2>/dev/null)

# Host specific overrides
FILENAME="$(dirname $BASH_SOURCE)/$(echo $(basename $BASH_SOURCE) | sed "s/\.sh/_$(hostname).sh/g")"
[ -f "$FILENAME" ] && source "$FILENAME"
unset FILENAME
