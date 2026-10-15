#!/bin/bash

## install PhpMyAdmin Application

IP=$(hostname -I | awk '{print $2}')
APT_OPT="-o Dpkg::Progress-Fancy="0" -q -y"
LOG_FILE="/vagrant/logs/install_myadmin.log"
export DEBIAN_FRONTEND="noninteractive"

VERSION="5.2.3"
REP="/var/www/html"

echo "START - Installation of phpMyAdmin - "$IP

echo "[1] - Install required packages ...."
apt-get install $APT_OPT \
	unzip \
	openssl \
	php-mbstring \
	php-zip \
	php-gd \
	php-xml \
	php-pear \
	php-cgi \
    >> $LOG_FILE 2>&1

echo "[2] - download files"
wget -q https://files.phpmyadmin.net/phpMyAdmin/${VERSION}/phpMyAdmin-${VERSION}-all-languages.zip > /dev/null 2>/tmp/install_myadmin.log
unzip phpMyAdmin-${VERSION}-all-languages.zip -d ${REP} >> /tmp/install_myadmin.log 2>&1
rm phpMyAdmin-${VERSION}-all-languages.zip

echo "[3] - configuration files  "
ln -s ${REP}/phpMyAdmin-${VERSION}-all-languages ${REP}/myadmin
mkdir ${REP}/myadmin/tmp
chown www-data:www-data ${REP}/myadmin/tmp
randomBlowfishSecret=$(openssl rand -hex 16)
sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = '$randomBlowfishSecret'|" ${REP}/myadmin/config.sample.inc.php > ${REP}/myadmin/config.inc.php

mysql -e "CREATE DATABASE phpmyadmin"
mysql -e "CREATE USER 'pma'@'localhost' IDENTIFIED BY 'pmapass'"
mysql -e "GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'pma'@'localhost'"
mysql -e "GRANT ALL PRIVILEGES ON phpmyadmin.* to 'irdw'@'%'"
mysql < ${REP}/myadmin/sql/create_tables.sql 

echo "[4] Restarting Apache..."
service apache2 restart

cat <<EOF
Service installed at http://192.168.56.80/myadmin/

You will need to add a hosts file entry for:

username: irdw
password: network

EOF

echo "END - Configuration phpMyAdmin"
