#!/bin/sh -eux
# Fabrique l'OVA à distribuer à partir de la VM créée par `vagrant up`
# Usage : ./export-ova.sh 1.0.0
VERSION=${1:?version manquante, ex. ./export-ova.sh 1.0.0}
VM=srv-irdw
OVA=build/$VM-debian13-arm64-$VERSION.ova

vagrant ssh -c '[ "$(ls /lib/modules | wc -l)" -eq 1 ]' || { echo "Plusieurs noyaux : reconstruire la box d'abord"; exit 1; }

# Retire l'utilisateur vagrant, puis éteint la VM
vagrant ssh -c 'sudo systemd-run --on-active=2 /bin/sh -c "pkill -KILL -u vagrant; userdel -r vagrant; rm -f /etc/sudoers.d/vagrant; poweroff"'
until VBoxManage showvminfo $VM --machinereadable | grep -q '^VMState="poweroff"'; do sleep 2; done

VBoxManage sharedfolder remove $VM --name vagrant || true

mkdir -p build
VBoxManage export $VM -o "$OVA" --manifest
shasum -a 256 "$OVA" > "$OVA.sha256"
