readonly MOVEX_REPOS=$HOME/repos

# Folder layout for MOVEX repositories:
#
# $MOVE_REPOS/
# ├── t1
# │   ├── common
# │   ├── data
# │   ├── olddata
# │   └── transtor
# └── t2
#     ├── common
#     ├── data
#     ├── olddata
#     └── transtor
# ...


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
    ruby $AMOS_HOME/common/ci_support/create_branch.rb -j usommerl -p $JIRA_PASSWORD $@
}

_basename_to_upper() {
  echo "$(basename $1 | tr '[:lower:]' '[:upper:]')"
}

_show_branch() {
  printf "* %-10s: %s\n" "$(_basename_to_upper $1)" "$(git -C $1 rev-parse --abbrev-ref HEAD)"
}

_clean_repo() {
  echo "* Cleaning $(_basename_to_upper $1)"
  git -C $1 clean -f -d
}

_check_branches() {
  for path in "$AMOS_NAT" "${AMOS_NAT}-ng" "$AMOS_COMMON"; do
    [ -e "$path" ] && _show_branch "$path"
  done
}

_clean_repos() {
  for path in "$AMOS_NAT" "${AMOS_NAT}-ng" "$AMOS_COMMON"; do
    [ -e "$path" ] && _clean_repo "$path"
  done
}

_continue_make() {
  read -p 'Continue with project make (y/n) ? ' choice
  case "$choice" in
    y|Y ) echo true;;
    * ) echo false;;
  esac
}

_project_instance() {
  echo $(basename $(dirname "$AMOS_NAT"))
}

_set_dbuser_suffix() {
  local dbuser_suffix="_$(_project_instance)"
  sed -ri "s/(<.*$1>\s+:\s+)([\"\']?)(\w+)([\"\']?)/\1\2\U\3$dbuser_suffix\4/" $AMOS_NAT/config/$2
}

_reload_environment() {
  echo '* Reload environment'
  unset WORKSPACE
  source "${AMOS_NAT}/ci_support/set_env.sh"
}

_make_project() {
  local make_cmd='make install'
  case "$AMOS_PROJ" in
    transtor|russia ) make_cmd='ci_support/ci_make.sh';;
  esac
  cd $AMOS_NAT
  time $make_cmd
}

generate_configs() {
  echo '* Generate configs'
  local vm_properties='env_sample_vm.yml'
  local default_properties='env_default_properties.yml'
  case "$AMOS_PROJ" in
    transtor ) vm_properties='env_vm_properties.yml';;
    russia ) vm_properties='env_amosVirtualBox.yml';;
  esac
  cd $AMOS_NAT/config
  _set_dbuser_suffix 'DBUSER' $vm_properties
  _set_dbuser_suffix 'DBUSER_CM' $default_properties
  ruby generate_configs.rb -p "$default_properties,$vm_properties"
  git checkout $default_properties $vm_properties
  cd $AMOS_NAT
}

movex_make() {
  if [ -z $AMOS_NAT ]; then
    echo 'Project environment not set'
    return
  fi
  local logfile="$MOVEX_REPOS/$(date --iso-8601=seconds)_$(_project_instance)_make.log"
  ( _check_branches
    if [ $(_continue_make) == false ]; then
      rm -f $logfile
      return
    fi
    _clean_repos
    generate_configs
    _reload_environment
    _make_project ) 2>&1 | tee $logfile
}

_create_aliases() {
  local dir
  for dir in $MOVEX_REPOS/*/; do
    local no=$(basename $dir | sed -r 's/\w+([0-9]+)/\1/')
    local inst=$(basename $(find $dir -maxdepth 1 -type d -iname transtor -o -iname sample -o -iname russia))
    alias ${inst}${no}="unset WORKSPACE; source ${dir}${inst}/ci_support/set_env.sh; cd ${dir}${inst}"
  done
}

_create_aliases
