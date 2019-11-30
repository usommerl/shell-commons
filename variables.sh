export MANPAGER='nvim -c "set ft=man" -'
export EDITOR=nvim
export LESS=-iR
export TEXMFHOME=$HOME/.texmf
export MPD_HOST=/$HOME/.mpd/socket
export PATH="${PATH}:$HOME/.local/bin"
export PATH="${PATH}:$HOME/.cargo/bin"

export FZF_DEFAULT_OPTS='--height 75% --multi --reverse --bind ctrl-f:page-down,ctrl-b:page-up'
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -100'"

if command -v fd >/dev/null; then
  export FZF_DEFAULT_COMMAND='fd -H --type f --color=never'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd -H --type d . --color=never'
fi

if command -v bat >/dev/null; then
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
fi

# Source host specific overrides
CURRENT_FILE="${BASH_SOURCE[0]:-${(%):-%x}}"
BASENAME="$(echo $(basename $CURRENT_FILE) | sed "s/\.sh/_$(hostname).sh/g")"
DIRNAME="$(dirname $CURRENT_FILE)"
OVERRIDE_FILE="$DIRNAME/$BASENAME"
[ -f "$OVERRIDE_FILE" ] && source "$OVERRIDE_FILE"
unset BASENAME DIRNAME CURRENT_FILE OVERRIDE_FILE
