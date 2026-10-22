#!/bin/sh -eu
# Vérifie la VM après `vagrant up` : phpMyAdmin et MariaDB joignables sur 192.168.56.80
curl -fsS -o /dev/null http://192.168.56.80/myadmin/
vagrant ssh -c 'mysql -uirdw -pnetwork -h 192.168.56.80 -e "USE tp_films"'
echo OK
