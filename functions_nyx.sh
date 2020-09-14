__bctl_connect() {
    bluetoothctl -- power off
    bluetoothctl -- power on
    bluetoothctl -- connect "$1"
}

bctl() {
  case $1 in
  off)
    bluetoothctl -- power off
    ;;
  btc22)
    __bctl_connect 70:B3:D5:94:A3:32
    ;;
  ueboom2)
    __bctl_connect 88:C6:26:C5:52:9B
    ;;
  aiaiai)
    __bctl_connect 00:08:E0:73:07:70
    ;;
  nubert)
    __bctl_connect CC:90:93:12:6D:C8
     ;;
  *)
    echo "Unknown argument: $1"
    ;;
  esac
}
