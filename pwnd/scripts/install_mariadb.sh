#!/bin/bash

## install MariaDB
export DEBIAN_FRONTEND=noninteractive

apt-get install -y mariadb-server

# Base accessible depuis l'hôte : MariaDB n'écoute que sur 127.0.0.1 par défaut
cat > /etc/mysql/mariadb.conf.d/99-irdw.cnf <<CNF
[mariadbd]
bind-address = 0.0.0.0
CNF
systemctl restart mariadb

mysql --version
