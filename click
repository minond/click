#!/bin/bash

if [ -f ~/.bash_aliases ]; then
  shopt -s expand_aliases
  source ~/.bash_aliases
fi

set -euo pipefail
out=$(eval $@ | tee /dev/tty)
set +euo pipefail

url=$(echo "$out" | grep -Eo '(http|https)://[a-zA-Z0-9./?=_-]*' | sort | uniq)
if [ $? -ne 0 ] || [ -z "$url" ]; then
  echo "no url found in output"
  exit
fi

open "$url"
