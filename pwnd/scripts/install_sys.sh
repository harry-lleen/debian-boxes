#!/bin/bash

## install base system

IP=$(hostname -I | awk '{print $2}')
NOM="irdw"
MDP="network"
HDIR="/var/www/html/irdw"

APT_OPT="-o Dpkg::Progress-Fancy="0" -q -y"
LOG_FILE="/vagrant/logs/install_sys.log"
export DEBIAN_FRONTEND=noninteractive

echo "START - install Server - "$IP

echo "=> [1]: Installing required packages..."
apt-get update $APT_OPT \
  >> $LOG_FILE 2>&1

apt-get install $APT_OPT \
  wget \
  gnupg \
  unzip \
  >> $LOG_FILE 2>&1

# Compilateur et en-têtes du noyau : les Guest Additions se recompilent
# automatiquement après une mise à jour du noyau
apt-get install $APT_OPT \
  build-essential \
  linux-headers-arm64 \
  >> $LOG_FILE 2>&1

echo "=> [2]: Server configuration"
# Ajout de contrib et non-free pour les depots
sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list
# Ajout de la ligne pour le proxy ESEO mais descativé
echo "#Acquire::http::Proxy \"http://scully.eseo.fr:9999\";" >> /etc/apt/apt.conf
# Pour avoir le clavier en français dans la console VB
# (variante mac : les touches d'un clavier Mac français donnent ce qui est imprimé dessus)
sed -i 's/XKBLAYOUT=\"us\"/XKBLAYOUT=\"fr\"/g' /etc/default/keyboard
sed -i 's/XKBVARIANT=\"\"/XKBVARIANT=\"mac\"/g' /etc/default/keyboard
# Configuration française comme la box chavinje/fr-book-64
sed -i 's/^# *fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen
locale-gen >> $LOG_FILE 2>&1
update-locale LANG=fr_FR.UTF-8
timedatectl set-timezone Europe/Paris
# /usr/bin/localectl set-keymap fr

# ajout utilisateur et autres
mkdir -p $HDIR
adduser --home $HDIR --disabled-password --no-create-home $NOM
echo $NOM:$MDP | chpasswd
chown $NOM $HDIR
chmod 755 $HDIR
usermod -aG sudo $NOM

echo "END - install Server"

