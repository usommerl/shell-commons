fail() {
  echo -e "\e[1;31m[fail]\e[0m $@"
  kill -INT $$ # kills only the function stack and not the entire shell
}

requires() {
  for arg in $*; do
      command -v $arg &> /dev/null || { fail "The command ‘$arg’ is required."; }
  done
}

bctl() {
  case $1 in
  off)
    bluetoothctl -- power off
    ;;
  btc22)
    bluetoothctl -- power off
    bluetoothctl -- power on
    bluetoothctl -- connect 70:B3:D5:94:A3:32
    ;;
  ueboom2)
    bluetoothctl -- power off
    bluetoothctl -- power on
    bluetoothctl -- connect 88:C6:26:C5:52:9B
    ;;
  aiaiai)
    bluetoothctl -- power off
    bluetoothctl -- power on
    bluetoothctl -- connect 00:08:E0:73:07:70
    ;;
  *)
    echo "Unknown argument: $1"
    ;;
  esac
}

