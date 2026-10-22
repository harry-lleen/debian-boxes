#!/bin/bash

## Configuration de la BDD

LOG_FILE="/vagrant/logs/install_bdd.log"
export DEBIAN_FRONTEND="noninteractive"

# [JCG] Utilisateur et base pris en charge par le fichier de création
DBFILE="files/creation_bdd_irdw.sql"

echo "=> [1]: Inject initial SQL file"
if [ -f "/vagrant/$DBFILE" ] ;then
  mysql < /vagrant/$DBFILE \
  #>> $LOG_FILE 2>&1
fi

echo "END - install MariaDB"

