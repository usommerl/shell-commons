
unlockSecrets() {
  local environment="$1"
  command -v dotenv-vault >/dev/null 2>&1 || { echo >&2 "doten-vault binary not installed"; return 1; }
  local password
  echo -n 'password:'
  read -s password
  eval "$(dotenv-vault -k $password decrypt ~/.secrets_$environment | sed 's/^/export /' | tr '\n' ';')"
  echo
}

consumerOffsets() {
  local host="$1"
  local configPath="$HOME/issues/IB-442/$host/client.properties"
  local groups=''

  groups="$(kafka-consumer-groups.sh --bootstrap-server "$host:9093" --command-config "$configPath" --list | grep 'egress\|router'| sort)"

  while read -r group; do
    kafka-consumer-groups.sh --bootstrap-server "$host:9093" --command-config "$configPath" --describe --group "$group"
  done <<< "$groups"
}

export -f consumerOffsets
