#!/bin/sh -eux
# Fabrique l'OVA à distribuer à partir de la VM créée par `vagrant up`
# Usage : ./export-ova.sh 1.0.0
VERSION=${1:?version manquante, ex. ./export-ova.sh 1.0.0}
VM=srv-irdw
OVA=build/$VM-debian13-arm64-$VERSION.ova

# Retire l'utilisateur vagrant (mot de passe vagrant, sudo sans mot de passe)
# puis éteint la VM ; différé de 2 s pour que la session SSH de Vagrant se termine
vagrant ssh -c 'sudo systemd-run --on-active=2 /bin/sh -c "pkill -KILL -u vagrant; userdel -r vagrant; rm -f /etc/sudoers.d/vagrant; poweroff"'
until VBoxManage showvminfo $VM --machinereadable | grep -q '^VMState="poweroff"'; do sleep 2; done

VBoxManage sharedfolder remove $VM --name vagrant || true

mkdir -p build
VBoxManage export $VM -o "$OVA" --manifest
shasum -a 256 "$OVA" > "$OVA.sha256"
# La VM n'a plus d'utilisateur vagrant : la supprimer ensuite avec `vagrant destroy -f`
