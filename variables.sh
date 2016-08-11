export EDITOR=nvim
export BROWSER=/usr/bin/chromium-browser
export LESS=-iR
export TEXMFHOME=$HOME/.texmf
export PATH="$HOME/.rbenv/shims:/opt/glassfish/glassfish/bin:/usr/nx/bin/:$HOME/.local/bin:$PATH"
export MPD_HOST=/$HOME/.mpd/socket
export TERM=xterm-256color
export JAVA_HOME=/opt/jdk1.6.0_45

# Sets LS_COLORS variable
eval $(dircolors $HOME/.dir_colors 2>/dev/null)

# osp
export CI_REPORTS=/tmp
export CI_CAPTURE=off

# vim: set filetype=sh:
