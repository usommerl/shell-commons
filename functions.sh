function _listFilterBase() {
    ls -lhHF $2 --color=always --group-directories-first \
                --time-style=long-iso $1 | egrep -v '^total'
}

function _onlyHiddenFilter() {
    egrep '.+[[:space:]]([[:cntrl:]]\[([[:digit:]]{2};)*[[:digit:]]{2}m)?\..+'
}

function _directoryFilter() { egrep $1 --color=never '^d'; }

function ldir() { _listFilterBase $1 | _directoryFilter; }

function lldir() { _listFilterBase $1 '-A' | _directoryFilter; }

function lhdir { lldir $1 | _onlyHiddenFilter; }

function lf() { _listFilterBase $1 | _directoryFilter '-v'; }

function llf() { _listFilterBase $1 '-A' | _directoryFilter '-v'; }

function lhf() { llf $1 | _onlyHiddenFilter; }

function lh() { _listFilterBase $1 '-A' | _onlyHiddenFilter; }

function lz() { du -xahL -d 1 $1 2>/dev/null | sort -h; }

function gitignoreTemplate() {
  if [ $# -gt 0 ]; then
      local baseURL='https://raw.githubusercontent.com/github/gitignore/master/'
      curl -fs ${baseURL}${1}.gitignore >> .gitignore
      if [ $? -ne 0 ]; then
          echo "Language template not found"
      fi
  else
      echo "Usage: $0 <language>"
  fi
}
