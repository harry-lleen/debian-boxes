#!/bin/sh -eux
# Configuration de la box et nettoyage.
# Lancement en root par Packer.
export DEBIAN_FRONTEND=noninteractive

# Vagrant : clés insecure (ed25519 + rsa), remplacées par Vagrant au premier up.
install -d -m 700 -o vagrant -g vagrant /home/vagrant/.ssh
install -m 600 -o vagrant -g vagrant /tmp/vagrant.pub /home/vagrant/.ssh/authorized_keys
rm /tmp/vagrant.pub

# SSH : pas de résolution DNS inverse.
printf 'UseDNS no\nGSSAPIAuthentication no\n' > /etc/ssh/sshd_config.d/10-vagrant.conf

# Réseau : eth0 quel que soit le modèle de carte.
sed -i 's/en[[:alnum:]]*/eth0/g' /etc/network/interfaces
sed -i -e 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' \
       -e 's/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/' /etc/default/grub
update-grub
# Chemin EFI de secours (\EFI\BOOT\BOOTAA64.EFI).
grub-install --target=arm64-efi --efi-directory=/boot/efi --removable

# Verrou apt pendant le provisioning.
systemctl disable --now apt-daily.timer apt-daily-upgrade.timer

# Guest Additions VirtualBox.
apt-get install -y build-essential dkms linux-headers-"$(uname -r)"
mkdir -p /mnt/vbox
mount -o loop,ro /tmp/VBoxGuestAdditions.iso /mnt/vbox
/mnt/vbox/VBoxLinuxAdditions-arm64.run --nox11 || true
# Noyau 5.10 (Debian 11) : TASK_SIZE_MAX n'existe pas encore sur arm64, vboxsf ne compile pas.
modinfo vboxsf >/dev/null 2>&1 || KCFLAGS=-DTASK_SIZE_MAX=TASK_SIZE_64 /sbin/rcvboxadd quicksetup all
umount /mnt/vbox
rm -rf /mnt/vbox /tmp/VBoxGuestAdditions.iso
modinfo vboxsf
apt-get purge -y build-essential dkms gcc make dpkg-dev linux-headers-"$(uname -r)"

dpkg-query -Wf '${Package}\n' 'linux-image-[0-9]*' | grep -v "$(uname -r)" | xargs -r apt-get purge -y

# Clés d'hôte SSH unique par VM
cat > /etc/systemd/system/ssh-hostkeys.service <<'EOF'
[Unit]
Description=Service de regénération des clés d'hôte SSH
Before=ssh.service
ConditionPathExists=!/etc/ssh/ssh_host_ed25519_key

[Service]
Type=oneshot
ExecStart=/usr/bin/ssh-keygen -A

[Install]
WantedBy=multi-user.target
EOF
systemctl enable ssh-hostkeys.service
rm -f /etc/ssh/ssh_host_*

# Cleanup
apt-get -y autoremove --purge
apt-get -y clean
rm -rf /var/lib/apt/lists/* /var/cache/* /tmp/* /var/tmp/* /var/log/vboxadd*
find /var/log -type f -exec truncate -s 0 {} +
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id /var/lib/systemd/random-seed /var/lib/dhcp/*
rm -f /root/.bash_history /home/vagrant/.bash_history
