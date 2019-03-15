fail() {
  echo -e "\e[1;31m[fail]\e[0m $@"
  kill -INT $$ # kills only the function stack and not the entire shell
}

requires() {
  for arg in $*; do
      command -v $arg &> /dev/null || { fail "The command ‘$arg’ is required."; }
  done
}

flac2mp3() {
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

rtmpSniffEnvironment() {
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

