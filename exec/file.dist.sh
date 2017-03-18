#!/usr/bin/env bash

SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

### IMPORT ENV VARIABLES ####
for file in $SCRIPT_DIR/../etc/env/*.conf; do
    if [[ $file == *".dist."* ]]; then
      continue
    fi

    IFS=$'\n'
    for variable in `cat $file`; do
        export $variable
    done
done

sshpass -p "$SSH_PASSWORD" \
rsync \
    -vrz  \
    --exclude '\.*' \
    -e ssh $SSH_USER@$SSH_HOST:"/var/www" '/backup/' --delete-before
