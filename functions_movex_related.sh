__basename_to_upper() {
  echo "$(basename $1 | tr '[:lower:]' '[:upper:]')"
}

__basename_to_lower() {
  echo "$(basename $1 | tr '[:upper:]' '[:lower:]')"
}

__show_branch() {
  printf "* %-10s: %s\n" "$(__basename_to_upper $1)" "$(git -C $1 rev-parse --abbrev-ref HEAD)"
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
  source "${AMOS_NAT}/ci_support/set_env.sh"
}

__make_project() {
  local make_cmd='make install'
  case "$(__basename_to_lower $AMOS_NAT)" in
    transtor|russia ) make_cmd='ci_support/ci_make.sh';;
  esac
  cd $AMOS_NAT
  time $make_cmd
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
      hww) alias ${inst}${no}="source ${dir}${inst}/config/hww.amosrc; cd ${dir}${inst}";;
      *) alias ${inst}${no}="unset WORKSPACE; source ${dir}${inst}/ci_support/set_env.sh; cd ${dir}${inst}";;
    esac
  done
}
movex_aliases

generate_configs() {
  local project=$(__basename_to_lower $AMOS_NAT)
  cd $AMOS_NAT/config
  echo "* Generate configs"
  case "$project" in
    hww ) __generate_configs_hww;;
    * ) __generate_configs_for "$project";;
  esac
  cd $AMOS_NAT
  git checkout config
}

__generate_configs_hww() {
  cd $AMOS_NAT/config
  local vm_properties='env/env_hww_vm.yml'
  [ -f 'env/env_default_properties.yml' ] && local default_properties='env/env_default_properties.yml,'
  __set_dbuser_suffix 'DBUSER' $vm_properties
  ruby generate_configs.rb -p "$default_properties$vm_properties" -t env/env_hww_templates.yml
}

__generate_configs_for() {
  local vm_properties='env_sample_vm.yml'
  local default_properties='env_default_properties.yml'
  case "$1" in
    transtor ) vm_properties='env_vm_properties.yml';;
    russia ) vm_properties='env_amosVirtualBox.yml';;
  esac
  __set_dbuser_suffix 'DBUSER' $vm_properties
  __set_dbuser_suffix 'DBUSER_CM' $default_properties
  ruby generate_configs.rb -p "$default_properties,$vm_properties"
}

movex_make() {
  if [ -z $AMOS_NAT ]; then
    echo 'Project environment not set'
    return
  fi
  local logfile="$MOVEX_REPOS/$(date --iso-8601=seconds)_$(__project_instance)_make.log"
  ( __check_branches
    if [ $(__continue_make) == false ]; then
      rm -f $logfile
      return
    fi
    __clean_repos
    generate_configs
    __reload_environment
    __make_project ) 2>&1 | tee $logfile
}
