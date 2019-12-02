# custom commands
alias rdsktp="rdesktop -g 100% -PKD -k de -z -x l -r sound:off -r clipboard:CLIPBOARD"
alias vncScreenShare="x11vnc -safer -nopw -viewonly -shared -forever -threads -noxdamage -mdns"
# reset urxvt terminal
alias cls="echo -ne '\033c'"

# modified commands
alias diff='colordiff'              # requires colordiff package
alias grep='grep --color=auto'
alias more='less'
alias df='df -h -x tmpfs -x devtmpfs -x rootfs -x ecryptfs'
alias di='di -ss -x tmpfs,run,ecryptfs'
alias du='du -c -h'
alias mkdir='mkdir -p -v'
alias ping='ping -c 5'
alias ..='cd ..'
alias hi='HISTTIMEFORMAT="%d.%m.%Y %T  ";history'
alias watch='watch --color'
alias nvlc='nvlc --no-color'

# ls
alias ls='ls -lhF --color=auto --time-style=long-iso'
alias l='ls -H --group-directories-first'
alias ll='ls -HA --group-directories-first'
alias lt='ls -HAtr'

# require root privileges
alias vpnc='sudo vpnc'
alias vpnc-disconnect='sudo vpnc-disconnect'

# shortcuts
alias ,.="cd -"
alias g="git"
alias d='docker'
alias c='docker-compose'
alias k='kubectl'
alias kc='kubectx'
alias kn='kubens'
alias h="hg"
alias v='nvim'
alias fe='fzf_find_edit'
alias fg='fzf_grep_edit'
alias vi='nvim'
alias vim='nvim'
alias vbm='VBoxManage'
alias lswifi="nmcli -f in-use,signal,ssid,bars,mode,security dev wifi | sort -n -k 1.3"
alias ext-ip='curl icanhazip.com'
alias mtr='mtr --curses'
alias jsonPager='jq "." | nvim -c "set ft=json" -'

alias luatexfonts='cat ~/.texlive/texmf-var/luatex-cache/generic/names/otfl-names.lua | grep familyname | cut -d "\"" -f 4 | sort | uniq'

# Source host specific overrides
CURRENT_FILE="${BASH_SOURCE[0]:-${(%):-%x}}"
BASENAME="$(echo $(basename $CURRENT_FILE) | sed "s/\.sh/_$(hostname).sh/g")"
DIRNAME="$(dirname $CURRENT_FILE)"
OVERRIDE_FILE="$DIRNAME/$BASENAME"
[ -f "$OVERRIDE_FILE" ] && source "$OVERRIDE_FILE"
unset BASENAME DIRNAME CURRENT_FILE OVERRIDE_FILE
