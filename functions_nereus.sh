
unlockSecrets() {
  local environment="$1"
  command -v dotenv-vault >/dev/null 2>&1 || { echo >&2 "doten-vault binary not installed"; return 1; }
  local password
  echo -n 'password:'
  read -s password
  eval "$(dotenv-vault -k $password decrypt ~/.secrets_$environment | sed 's/^/export /' | tr '\n' ';')"
  echo
}
