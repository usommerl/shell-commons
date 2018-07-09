REPOS_ROOT="$HOME/repos"

trigger_jenkins() {
  local jenkins_url='https://dev.exelonix.com/jenkins'
  local scm_url='https://dev.exelonix.com/hg/IoT'
  local repo="$(basename $(pwd))"
  curl "${jenkins_url}/git/notifyCommit?url=${scm_url}/${repo}"
}
