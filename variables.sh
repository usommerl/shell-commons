export MANPAGER='nvim -c "set ft=man" -'
export EDITOR=nvim
export LESS=-iR
export TEXMFHOME=$HOME/.texmf
export MPD_HOST=/$HOME/.mpd/socket
export TERM=rxvt-256color
export CHROME_BIN="$(which chromium)"

export PATH="${PATH}:$HOME/.local/bin"
export PATH="${PATH}:$HOME/.cargo/bin"
export PATH="${PATH}:$ANDROID_HOME/tools/bin"
export PATH="${PATH}:$ANDROID_HOME/platform-tools"
export PATH="${PATH}:$HOME/.yarn-global/bin"
export PATH="${PATH}:/opt/glassfish/bin"
export PATH="${PATH}:$HOME/genymotion"
export PATH="${PATH}:/opt/STM32CubeProgrammer/bin"


# Sets LS_COLORS variable
eval $(dircolors $HOME/.dir_colors 2>/dev/null)

# vim: set filetype=sh:
