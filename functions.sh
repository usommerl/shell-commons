_listFilterBase() {
  ls -lhHF $2 --color=always --group-directories-first \
              --time-style=long-iso $1 | egrep -v '^total'
}

_onlyHiddenFilter() {
  egrep '.+[[:space:]]([[:cntrl:]]\[([[:digit:]]{2};)*[[:digit:]]{2}m)?\..+'
}

_directoryFilter() { egrep $1 --color=never '^d'; }

ldir() { _listFilterBase $1 | _directoryFilter; }

lldir() { _listFilterBase $1 '-A' | _directoryFilter; }

lhdir() { lldir $1 | _onlyHiddenFilter; }

lf() { _listFilterBase $1 | _directoryFilter '-v'; }

llf() { _listFilterBase $1 '-A' | _directoryFilter '-v'; }

lhf() { llf $1 | _onlyHiddenFilter; }

lh() { _listFilterBase $1 '-A' | _onlyHiddenFilter; }

lz() { du -xahL -d 1 $1 2>/dev/null | sort -h; }

gitignoreTemplate() {
  if [ $# -gt 0 ]; then
      local baseURL='https://raw.githubusercontent.com/github/gitignore/master/'
      curl -fs ${baseURL}${1}.gitignore >> .gitignore
      if [ $? -ne 0 ]; then
          echo "Language template not found"
      fi
  else
      echo "Usage: $0 <language>"
  fi
}

__setColorscheme() {
  echo -e "URxvt.cursorColor: $1\n*background: $2\n*foreground: $3" | xrdb -merge
  killall -s HUP awesome
}

colorscheme() {
   local light='light'
   local dark='dark'
   case $1 in
    $light )
        __setColorscheme "9" "#FFFFFF" "#000000"
        ;;
    $dark )
        __setColorscheme "11" "#000000" "#babdb6"
        ;;
    *)
        echo "Usage: $0 <$light|$dark>"
   esac
}

fingerprints() {
  ssh-keygen -E md5 -lf <(ssh-keyscan "$1" 2>/dev/null)
}

checkFingerprint() {
 export GREP_COLORS="mt=01;32"
 fingerprints "$1" | grep "$2" && echo -e "\033[1;32mVALID\033[0m" || echo -e "\033[1;31mINVALID\033[0m"
 unset GREP_COLORS
}

string2Hex() {
  echo -n "$1" | od -A n -t x1 -w"${2:4096}"| sed 's/ *//g'
}

hex2string () {
  local i=0
  while [ $i -lt ${#1} ];
  do
    echo -en "\x"${1:$i:2}
    let "i += 2"
  done
  echo
}

cat() {
  if command -v bat >/dev/null 2>&1; then
    bat "$@"
  else
    command cat "$@"
  fi
}

# Source host specific overrides
CURRENT_FILE="${BASH_SOURCE[0]:-${(%):-%x}}"
BASENAME="$(echo $(basename $CURRENT_FILE) | sed "s/\.sh/_$(hostname).sh/g")"
DIRNAME="$(dirname $CURRENT_FILE)"
OVERRIDE_FILE="$DIRNAME/$BASENAME"
[ -f "$OVERRIDE_FILE" ] && source "$OVERRIDE_FILE"
unset BASENAME DIRNAME CURRENT_FILE OVERRIDE_FILE
