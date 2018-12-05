#!/bin/bash

#=== FUNCTION =================================================================
#         NAME: arg_or_read
#  DESCRIPTION: Return given argument iff set, reads from stdin otherwise.
#  PARAMETER 1: Optional argument value.
#==============================================================================
arg_or_read() {
  if [ ! -z "${1:-}" ]; then
    echo "${1:-}"
  else
    read arg
    echo "$arg"
  fi
}

#=== FUNCTION =================================================================
#         NAME: env_eval
#  DESCRIPTION: Evaluates a bash expression in a similar environment as the
#               user's and crashes on first error.
#  PARAMETER *: Command and arguments
#==============================================================================
env_eval() {
  if [ -f ~/.bash_aliases ]; then
    shopt -s expand_aliases
    source ~/.bash_aliases
  fi

  set -euo pipefail
  out=$(eval $@ | tee /dev/tty)
  set +euo pipefail
  echo "$out"
}

#=== FUNCTION =================================================================
#         NAME: match_url
#  DESCRIPTION: Given any text or string, this will match and return a URL.
#  PARAMETER 1: String
#==============================================================================
match_url() {
  local text=$(arg_or_read "${1:-}")
  local match='(http|https)://[a-zA-Z0-9./?=_-]*'
  local url=$(echo "$text" | grep -Eo "$match")
  echo "$url"
}

#=== FUNCTION =================================================================
#         NAME: open_it
#  DESCRIPTION: Calls system's open command with a safeguard around the input.
#  PARAMETER 1: URI string
#==============================================================================
open_it() {
  local url=$(arg_or_read "${1:-}")
  if [ ! -z "$url" ]; then
    open "$url"
  fi
}

if [ ! -z "${1:-}" ]; then
  env_eval $@ | match_url | open_it
elif [ ! -t 0 ]; then
  cat | match_url | open_it
fi
