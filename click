#!/bin/bash

#=== FUNCTION =================================================================
#         NAME: open_url
#  DESCRIPTION: If a URL is found in the argument, open it and exit this program.
#  PARAMETER 1: Any string
#         TODO: Add a way for a user to prioritise URLs.
#==============================================================================
open_url() {
  local text="${1:-}"
  local match='(http|https)://[a-zA-Z0-9./?=_-]*'
  local url=$(echo "$text" | grep -Eo "$match")

  if [ ! -z "$url" ]; then
    open "$url"
    exit
  fi
}

#=== FUNCTION =================================================================
#         NAME: read_all_and_find_url
#  DESCRIPTION: Reads piped input and calls open_url on every line.
#        STDIN: Any string
#==============================================================================
read_all() {
  while read line
  do
    open_url "$line"
  done
}

if [ ! -z "${1:-}" ]; then
  # Execute given arguments as a command. Before doing so, try loading the
  # user's aliases so they can use them as arguments to this command.
  if [ -f ~/.bash_aliases ]; then
    shopt -s expand_aliases
    source ~/.bash_aliases
  fi

  # Evaluate everything from here in strict settings. This is to prevent bad
  # arguments from going forward.
  set -euo pipefail
  eval $@ | tee /dev/tty | read_all
elif [ ! -t 0 ]; then
  # Input is coming in from standard input. Easy.
  read_all
elif [ ! -z "${TMUX:-}" ]; then
  # Capture last N lines from the current tmux pane and read the lines in
  # reverse order since we prefer newer output over older one.
  file=$(mktemp)
  tmux capture-pane -pS -1000 > "$file"
  tail -r "$file" | read_all
  rm "$file"
else
  echo I need some sort of input or for you to run me in tmux!
fi
