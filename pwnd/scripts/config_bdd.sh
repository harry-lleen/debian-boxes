#!/bin/bash

## Configuration de la BDD

IP=$(hostname -I | awk '{print $2}')
APT_OPT="-o Dpkg::Progress-Fancy="0" -q -y"
LOG_FILE="/vagrant/logs/install_bdd.log"
export DEBIAN_FRONTEND="noninteractive"

# [JCG] Pris en charge par le fichier de création
USER=""
PASSWDDB=""
DBNAME=""
DBFILE="files/creation_bdd_irdw.sql"

echo "=> [1]: Create USER and DATABASE"
if [ -n "$DBNAME" ] && [ -n "$DBUSER" ] && [ -n "$DBPASSWD" ] ;then
  mysql -e "CREATE DATABASE $DBNAME" \
  >> $LOG_FILE 2>&1
  mysql -e "grant all privileges on $DBNAME.* to '$DBUSER'@'%' identified by '$DBPASSWD'" \
  >> $LOG_FILE 2>&1
fi

echo "=> [2]: Inject initial SQL file"
if [ -f "/vagrant/$DBFILE" ] ;then
  mysql < /vagrant/$DBFILE \
  #>> $LOG_FILE 2>&1
fi

echo "END - install MariaDB"

