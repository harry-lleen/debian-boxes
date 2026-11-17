# Box Vagrant Debian arm64 (VirtualBox, Apple Silicon)

Box Debian 11 (bullseye), 12 (bookworm), 13 (trixie) et Kali, construites avec Packer.

## Utiliser une box

```ruby
Vagrant.configure("2") do |config|
  config.vm.box     = "harry-lleen/debian-13"
  config.vm.box_url = "https://harry-lleen.github.io/debian-boxes/debian-13.json"
end
```

Ou importer la box directement :

```sh
vagrant box add https://harry-lleen.github.io/debian-boxes/debian-13.json
```

Il faut VirtualBox 7.1 ou plus récent sur un Mac Apple Silicon. `vagrant box update` récupère les nouvelles versions publiées.

## Contenu

- Installation netinst minimale (`standard` + `ssh-server`) avec `sudo`, `curl` et `python3`.
- Utilisateur `vagrant`/`vagrant` avec sudo sans mot de passe et les clés insecure Vagrant (ed25519 + rsa), remplacées au premier `vagrant up`.
- Pas de mot de passe root.
- Guest Additions VirtualBox.
- Locale `en_US.UTF-8`, clavier `us`, fuseau UTC, interface réseau `eth0`, GRUB sans délai.
- Chaque VM a ses propres clés d'hôte SSH, générées au premier boot, et son propre `machine-id`.
- Tâches apt automatiques désactivées.

Après une mise à jour du noyau dans la VM, le dossier partagé n'est plus monté tant que les Guest Additions ne sont pas recompilées :

```sh
sudo apt install build-essential linux-headers-$(uname -r) && sudo /sbin/rcvboxadd quicksetup all
```

## Construire

```sh
packer init .
packer build -var-file=debian-13.pkrvars.hcl .   # → build/debian-13-arm64-13.7.0.virtualbox.box
packer build -var-file=debian-12.pkrvars.hcl .   # → build/debian-12-arm64-12.15.0.virtualbox.box
packer build -var-file=debian-11.pkrvars.hcl .   # → build/debian-11-arm64-11.11.0.virtualbox.box
packer build -var-file=kali.pkrvars.hcl .        # → build/kali-arm64-2026.3.virtualbox.box
```

Il faut 15 à 25 minutes par box. Pour passer à une nouvelle version mineure de Debian, mettre à jour l'URL et le SHA256 dans `debian-XX.pkrvars.hcl` (le SHA256 se trouve dans le fichier `SHA256SUMS` de cdimage.debian.org).

Pour tester une box localement :

```sh
vagrant box add --name test/debian-13 build/debian-13-arm64-13.7.0.virtualbox.box
```

## Fichiers

| Fichier | Rôle |
| --- | --- |
| `debian.pkr.hcl` | Template Packer |
| `debian-XX.pkrvars.hcl`, `kali.pkrvars.hcl` | ISO et checksum de chaque version |
| `http/preseed.cfg` | Réponses de l'installateur Debian |
| `scripts/provision.sh` | Configuration, Guest Additions, nettoyage |
| `scripts/minimize.sh` | Remplit l'espace libre de zéros pour mieux compresser la box |
| `publish.sh` | Release GitHub et mise à jour du catalogue |

Template adapté de [chef/bento](https://github.com/chef/bento) (Apache-2.0).

## Kali

Box `harry-lleen/kali` : Kali rolling arm64, base `kali-linux-core` et outils `kali-tools-top10` (nmap, metasploit, sqlmap, hydra, john, aircrack-ng, responder, netexec…), sans interface graphique. Burp Suite n'existe pas en arm64.

```ruby
Vagrant.configure("2") do |config|
  config.vm.box     = "harry-lleen/kali"
  config.vm.box_url = "https://harry-lleen.github.io/debian-boxes/kali.json"
end
```

Bureau Xfce, à ajouter dans le bloc ci-dessus :

```ruby
  config.vm.provider :virtualbox do |v|
    v.gui    = true
    v.memory = 4096
    v.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga", "--vram", "128"]
  end
  config.vm.provision "shell", inline: "export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y kali-desktop-xfce && systemctl isolate graphical.target"
```

## OVA du cours IRDW (projet PWND)

Le dossier [`pwnd/`](pwnd/) est destiné à la création d'une VM préconfigurée (Apache, PHP, MariaDB, phpMyAdmin) basée sur la box `harry-lleen/debian-13`, puis exporte la VM en OVA. L'OVA est publié dans les releases `pwnd-v*`.

Vagrantfile et scripts de Jérôme Chavin-Gazalier ([@chavinje](https://github.com/chavinje)), adaptés pour Mac Apple Silicon.
