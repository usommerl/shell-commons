export MANPAGER='nvim -c "set ft=man" -'
export EDITOR=nvim
export LESS=-iR
export TEXMFHOME=$HOME/.texmf
export MPD_HOST=/$HOME/.mpd/socket
export TERM=rxvt-256color
export PATH="${PATH}:$HOME/.local/bin"
export PATH="${PATH}:$HOME/.cargo/bin"

# Source host specific overrides
CURRENT_FILE="${BASH_SOURCE[0]:-${(%):-%x}}"
BASENAME="$(echo $(basename $CURRENT_FILE) | sed "s/\.sh/_$(hostname).sh/g")"
DIRNAME="$(dirname $CURRENT_FILE)"
OVERRIDE_FILE="$DIRNAME/$BASENAME"
[ -f "$OVERRIDE_FILE" ] && source "$OVERRIDE_FILE"
unset BASENAME DIRNAME CURRENT_FILE OVERRIDE_FILE
