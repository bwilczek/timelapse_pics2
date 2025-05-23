#!/bin/bash

# set -euo pipefail
# set -x
# IFS=$'\n\t'

SRC_ROOT=/home/ftp/upload/

FILES=$(find $SRC_ROOT  -type f -iname "*.jpg")

for file in $FILES; do
  bundle exec handle_file.rb "$file"
  if [ $? -eq 0 ]; then
    rm "$file"
  fi
done
