#!/usr/bin/env bash

SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

### IMPORT ENV VARIABLES ####
for file in $SCRIPT_DIR/../etc/env/*; do
    if [[ $file == *".dist"* ]]; then
      continue
    fi

    IFS=$'\n'
    for variable in `cat $file`; do
        export $variable
    done
done

DATE=`date +"%Y-%m-%d"`
TIME=`date +"%H-%M"`
MYSQL="mysql -u$DB_USER -p$DB_PASSWORD"
MYSQLDUMP="mysqldump -u$DB_USER -p$DB_PASSWORD"

DATABASES=$(sshpass -p $SSH_PASSWORD ssh $SSH_USER@$SSH_HOST "$MYSQL -e \"SHOW DATABASES;\"" | tr -d "| " | grep -v Database)
for DB in $DATABASES; do
    # skip databases
    [ "$DB" == "information_schema" ] && continue
    [ "$DB" == "performance_schema" ] && continue
    [ "$DB" == "mysql" ] && continue

    DESDIR="$PATH_BACKUP_DATABASE_DIR$DATE/"
    FILEPATH="$DESDIR$DB-$TIME.sql.gz"

    if [ ! -d "$DESDIR" ]; then
        mkdir -p $DESDIR
    fi

    sshpass -p $SSH_PASSWORD ssh $SSH_USER@$SSH_HOST \
    "$MYSQLDUMP --single-transaction --databases $DB | gzip -9 -c" > "$FILEPATH"
done