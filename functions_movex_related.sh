__basename_to_upper() {
  echo "$(basename $1 | tr '[:lower:]' '[:upper:]')"
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
  source "${AMOS_NAT}/ci_support/set_env.sh"
}

__make_project() {
  local make_cmd='make install'
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
  local arg=$(__generate_configs_arg)
  echo "* generate_configs.rb $arg"
  __alter_dbuser
  cd $AMOS_NAT/config
  generate_configs.rb $arg
  cd $AMOS_NAT
  git checkout config
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
