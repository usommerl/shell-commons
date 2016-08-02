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
alias h='history'
alias watch='watch --color'
alias nvlc='nvlc --no-color'
alias vim="vim --servername $VIM_SERVERNAME"
alias vir="vim --servername $VIM_SERVERNAME --remote-silent"
alias sqlplus='rlwrap sqlplus'

# ls
alias ls_base='ls -lhF --color=auto --time-style=long-iso'
alias l='ls_base -H --group-directories-first'
alias ll='ls_base -HA --group-directories-first'
alias lt='ls_base -HAtr'

# require root privileges
alias vpnc='sudo vpnc'
alias vpnc-disconnect='sudo vpnc-disconnect'
alias docker='sudo -E docker'

# shortcuts
alias vbm='VBoxManage'
alias g="git" # further git aliases in gitconfig
alias lswifi="nmcli -f signal,ssid,security dev wifi | sort -n"
alias ext-ip='curl icanhazip.com'
alias luatexfonts='cat ~/.texlive/texmf-var/luatex-cache/generic/names/otfl-names.lua | grep familyname | cut -d "\"" -f 4 | sort | uniq'
alias ack='ack-grep'

# osp
alias set_proxy='export http_proxy=http://proxy.osp-dd.de:3128; export https_proxy=http://proxy.osp-dd.de:3128'
alias unset_proxy='unset http_proxy; unset https_proxy'
# vim: set filetype=sh: