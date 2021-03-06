export PATH="${PATH}:$HOME/.local/kafka/bin"
export PATH="${PATH}:$HOME/.yarn-global/bin"
export PATH="${PATH}:$HOME/.pyenv/bin"
export PATH="${PATH}:$HOME/genymotion"
export PATH="${PATH}:$ANDROID_HOME/tools/bin"
export PATH="${PATH}:$ANDROID_HOME/platform-tools"
export PATH="${PATH}:/opt/STM32CubeProgrammer/bin"

export CHROME_BIN="$(which chromium)"

# Set LS_COLORS variable
eval $(dircolors $HOME/.dir_colors 2>/dev/null)
