readonly HTTP_USER='usommerl'

__check_http_credentials() {
  local url="${1:-http://jira.osp-dd.de}"
  echo "$(curl -s -o /dev/null -w '%{http_code}' -u "$HTTP_USER:$HTTP_PASS" "$url")"
}

ask_http_password() {
  if [ -z "$HTTP_PASS" ]; then
    while [ "$(__check_http_credentials)" == '401' ]; do
      printf 'password: ' && read -s HTTP_PASS && printf "\e[0K\r"
    done
    export HTTP_PASS
  fi
}

__basename_to_upper() {
  echo "$(basename $1 | tr '[:lower:]' '[:upper:]')"
}

__show_branch() {
  local project=$(__basename_to_upper $1)
  local branch=$(git -C $1 rev-parse --abbrev-ref HEAD)
  local untracked=$(git -C $1 status --porcelain 2>/dev/null| grep "^??" | wc -l)
  [ $untracked -gt 0 ] && local warning="$untracked file(s) will be cleaned!"
  printf "* %-10s: %s \e[1;33m%30s\e[m\n" "$project" "$branch" "$warning"
}

__clean_repo() {
  echo "* Cleaning $(__basename_to_upper $1)"
  git -C $1 clean -f -d
}

__check_branches() {
  for path in "$AMOS_NAT" "${AMOS_NAT}-ng" "$AMOS_COMMON"; do
    [ -e "$path" ] && __show_branch "$path"
  done
}

__clean_repos() {
  for path in "$AMOS_NAT" "${AMOS_NAT}-ng" "$AMOS_COMMON"; do
    [ -e "$path" ] && __clean_repo "$path"
  done
}

__continue_make() {
  read -p 'Continue with project make (y/n) ? ' choice
  case "$choice" in
    y|Y ) echo true;;
    * ) echo false;;
  esac
}

__project() {
  echo "$(basename $AMOS_NAT | tr '[:upper:]' '[:lower:]')"
}
__project_instance() {
  echo $(basename $(dirname "$AMOS_NAT"))
}

__set_dbuser_suffix() {
  local dbuser_suffix="_$(__project_instance)"
  sed -ri "s/(<.*$1>\s+:\s+)([\"\']?)(\w+)([\"\']?)/\1\2\U\3$dbuser_suffix\4/" $AMOS_NAT/config/$2
}

__reload_environment() {
  echo '* Reload environment'
  unset WORKSPACE
  case "$(__project)" in
    hww ) source $AMOS_NAT/config/hww.amosrc;;
    transtor ) source $AMOS_NAT/ci_support/set_env.sh; unset RAILS_ENV;;
    * ) source $AMOS_NAT/ci_support/set_env.sh;;
  esac
}

__make_project() {
  local make_cmd='make clean install'
  case "$(__project)" in
    transtor|russia ) make_cmd='ci_support/ci_make.sh';;
  esac
  cd $AMOS_NAT
  time $make_cmd
}

__property_files() {
  local default_properties=$(find $AMOS_NAT/config -iname env_default_properties.yml \
                             | sed -e 's/^.*config\///')
  case "$(__project)" in
    sample ) local vm_properties='env_sample_vm.yml';;
    transtor ) local vm_properties='env_vm_properties.yml';;
    russia ) local vm_properties='env_amosVirtualBox.yml';;
    hww ) local vm_properties='env/env_hww_vm.yml';;
  esac
  echo "local default_properties=$default_properties; local vm_properties=$vm_properties"
}

__alter_dbuser() {
  eval $(__property_files)
  __set_dbuser_suffix 'DBUSER' $vm_properties
  [ "$(__project)" == "russia" ] && __set_dbuser_suffix 'DBUSER_CM' $default_properties
}

__generate_configs_arg() {
  eval $(__property_files)
  local arg="-p "
  [ ! -z "$default_properties" ] && arg="${arg}${default_properties},"
  arg=${arg}${vm_properties}
  [ "$(__project)" == "hww" ] && arg="${arg} -t env/env_hww_templates.yml"
  echo $arg
}

# Folder layout for MOVEX repositories:
#
# $MOVEX_REPOS/
# ├── t1
# │   ├── common
# │   ├── data
# │   ├── olddata
# │   └── transtor
# ├── t2
# │   ├── common
# │   ├── data
# │   ├── olddata
# │   └── transtor
# └── s1
#     ├── common
#     ├── data
#     ├── olddata
#     └── sample
# ...

readonly MOVEX_REPOS=$HOME/repos

movex_aliases() {
  local dir
  for dir in $MOVEX_REPOS/*/; do
    local no=$(basename $dir | sed -r 's/\w+([0-9]+)/\1/')
    local inst=$(find $dir -maxdepth 1 -type d -iname transtor -o -iname sample \
                           -o -iname russia -o -iname hww | sed -r 's/.*\/(\w+)$/\1/')
    [[ -z "$no" || -z "$inst" ]] && continue
    case "$inst" in
      hww) alias $(basename $dir)="source ${dir}${inst}/config/hww.amosrc; cd ${dir}${inst}";;
      *) alias $(basename $dir)="unset WORKSPACE; source ${dir}${inst}/ci_support/set_env.sh; cd ${dir}${inst}";;
    esac
  done
}
movex_aliases

generate_configs() {
  eval $(__property_files)
  local arg=$(__generate_configs_arg)
  echo "* generate_configs.rb $arg"
  __alter_dbuser
  cd $AMOS_NAT/config
  generate_configs.rb $arg
  git checkout $vm_properties $default_properties
  cd $AMOS_NAT
}

movex_make() {
  [ -z $AMOS_NAT ] && echo 'You need to set at least AMOS_NAT' && return
  local logfile="$MOVEX_REPOS/$(date --iso-8601=seconds)_$(__project_instance)_make.log"
  ( __check_branches
    [ $(__continue_make) == false ] && rm -f $logfile && return
    printf "\n"
    __clean_repos
    generate_configs
    __reload_environment
    __make_project ) 2>&1 | tee >(sed -u 's/\x1b\[[0-9;]*m//g' > $logfile)
}

dp_test_environment() {
  if [ -z $AMOS_NAT ]; then
    echo 'Project environment not set'
  else
    export RUBYLIB="$AMOS_NAT/ci_support/rubylib:$RUBYLIB"
  fi
}

create_branch() {
  printf "Insert JIRA password: "
  read -s JIRA_PASSWORD
  printf "\n"
  ruby $AMOS_COMMON/ci_support/create_branch.rb -j usommerl -p $JIRA_PASSWORD $@
}

__jira_transition_command() {
  local issue="$1"
  local transition_id="$2"
  local username="$3"
  local password="$4"
  local url="http://jira.osp-dd.de/rest/api/latest/issue/$issue/transitions?expand=transitions.fields"
  local data="{\"transition\":{\"id\": \"$transition_id\"}}"
  local content_type='Content-Type: application/json'
  echo "curl -D- --user '$username:$password' -X POST --data '$data' -H '$content_type' '$url'"
}

jira_transition() {
  local issue="$1"
  local transition_id="$2"
  ask_http_password
  eval "$(__jira_transition_command "$issue" "$transition_id" "$HTTP_USER" "$HTTP_PASS")"
}

__trigger_ci_command() {
  local job="$1"
  local issue="$2"
  local token="$3"
  local username="$4"
  local password="$5"
  local url="http://movex-ci.osp-dd.de/job/$job/buildWithParameters?token=$token&manual_issue_key=$issue"
  echo "curl --user '$username:$password' '$url'"
}

trigger_ci() {
  ask_http_password
  local job="$1"
  local issue="$2"
  local start="${3:-now}"
  local token="${4:-$job}"
  local jira_transition=$(__jira_transition_command "$issue" "51" "$HTTP_USER" "$HTTP_PASS")
  local trigger_ci=$(__trigger_ci_command "$job" "$issue" "$token" "$HTTP_USER" "$HTTP_PASS")
  echo "$jira_transition; $trigger_ci" | at $start
}

__datediff() {
  local d1=$(date -d "$1" +%s)
  local d2=$(date -d "$2" +%s)
  local factor="$3"
  local result="$(printf '%s\n' "($d1 - $d2) / $factor" | bc -l)"
  printf '%s' "$result"
}

build_queue() {
  ask_http_password
  local url='http://movex-ci.osp-dd.de/queue/api/json?'
  local json=$(curl -s -X POST -u "$HTTP_USER:$HTTP_PASS" $url)
  local jmespath="items[].join(', ',[to_string(actions[0].parameters[0].value), \
                                     to_string(task.name),                      \
                                     to_string(actions[1].causes[0].userName),  \
                                     to_string(inQueueSince)                    \
                                    ])"
  local json_projection="$(echo "$json" | jp "$jmespath")"
  while IFS=, read ticket pipeline name timestamp; do
    local seconds="$(printf '%.0f' "$(printf '%.0f / 1000\n' "$timestamp" | bc -l)")"
    local hours_in_queue="$(printf '%.2f' "$(__datediff 'now' "$(date -u -d @"$seconds")" 3600)")"
    printf "%-35s %-35s %-35s %11s hours\n" "$ticket" "$pipeline" "$name" "$hours_in_queue"
  done <<<"$(echo "$json_projection" | tr -d '["]' | sed -e '/^\s*$/d' -e 's/^ *//' -e 's/ *, */,/')"
}
