function fail() {
    echo -e "\e[1;31m[fail]\e[0m $@"
    kill -INT $$ # kills only the function stack and not the entire shell
}

function requires() {
    for arg in $*; do
        command -v $arg &> /dev/null || { fail "The command ‘$arg’ is required."; }
    done
}

function _listFilterBase() {
    ls -lhHF $2 --color=always --group-directories-first \
                --time-style=long-iso $1 | egrep -v '^total'
}

function _onlyHiddenFilter() {
    egrep '.+[[:space:]]([[:cntrl:]]\[([[:digit:]]{2};)*[[:digit:]]{2}m)?\..+'
}

function _directoryFilter() { egrep $1 --color=never '^d'; }

function ldir() { _listFilterBase $1 | _directoryFilter; }

function lldir() { _listFilterBase $1 '-A' | _directoryFilter; }

function lhdir { lldir $1 | _onlyHiddenFilter; }

function lf() { _listFilterBase $1 | _directoryFilter '-v'; }

function llf() { _listFilterBase $1 '-A' | _directoryFilter '-v'; }

function lhf() { llf $1 | _onlyHiddenFilter; }

function lh() { _listFilterBase $1 '-A' | _onlyHiddenFilter; }

function lz() { du -xahL -d 1 $1 2>/dev/null | sort -h; }

function rtmpSniffEnvironment() {
   local setup='setup'
   local teardown='teardown'

   case $1 in
    $setup )
        sudo iptables -t nat -A OUTPUT -p tcp --dport 1935 -j REDIRECT
        rtmpsrv
        ;;
    $teardown )
        sudo iptables -t nat -D OUTPUT -p tcp --dport 1935 -j REDIRECT
        ;;
    *)
        echo "Usage: $0 <$setup|$teardown>"
   esac
}

function gitignoreTemplate() {
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

function _setColorscheme() {
    requires xrdb
    echo "URxvt.cursorColor: $1\\n*background: $2\\n*foreground: $3" | xrdb -merge
    killall -s HUP awesome
}

function colorscheme() {
   local light='light'
   local dark='dark'
   case $1 in
    $light )
        _setColorscheme "9" "#FFFFFF" "#000000"
        ;;
    $dark )
        _setColorscheme "11" "#000000" "#babdb6"
        ;;
    *)
        echo "Usage: $0 <$light|$dark>"
   esac
}

function flac2mp3() {
    requires ffmpeg
    requires parallel

    fileList=()
    local arg
    for arg in $@; do
        if [[ -d "$arg" ]]; then
            local OLDIFS=$IFS
            IFS=$'\n'
            files=( $(find "${arg%/}/" -maxdepth 1 -type f -iname "*.flac") )
            fileList=( ${fileList[@]} ${files[@]} )
            IFS=$OLDIFS
            unset files
        elif [[ -f "$arg"  &&  "${arg##*.}" == "flac" ]]; then
            fileList+=( "$arg" )
        fi
    done
    parallel --no-notice \
        'mp3File={.}.mp3;\
         if [ -f "$mp3File" ]; then echo -e "\e[1;33m[Skipped]\e[0m $mp3File"; fi;\
         ffmpeg -loglevel quiet -nostdin \
                -i {} -f mp3 -vn -ab 320000 "$mp3File";\
         if [ "$?" -eq 0 ]; then echo -e "\e[1;97m[Created]\e[0m $mp3File"; fi;' ::: "${fileList[@]}"
    unset fileList
}

# TODO allow arguments (i.e. -n)
function musicRename() {
  requires perl-rename
  perl-rename 'tr/A-Z/a-z/ && s/ /_/g && s/[_-]?[\(\[]?(\d{4}|flac)[\)\]]?//g' $1
}
# vim: set filetype=sh:
