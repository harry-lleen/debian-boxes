# Box Vagrant Debian arm64 (VirtualBox, Apple Silicon)

Box Debian 11 (bullseye), 12 (bookworm) et 13 (trixie), construites avec Packer.

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
| `debian-XX.pkrvars.hcl` | ISO et checksum de chaque version |
| `http/preseed.cfg` | Réponses de l'installateur Debian |
| `scripts/provision.sh` | Configuration, Guest Additions, nettoyage |
| `scripts/minimize.sh` | Remplit l'espace libre de zéros pour que la compression |
| `publish.sh` | Release GitHub et mise à jour du catalogue |

Template adapté de [chef/bento](https://github.com/chef/bento) (Apache-2.0).

## OVA du cours IRDW (projet PWND)

Le dossier [`pwnd/`](pwnd/) est destiné à la création d'une VM préconfigurée (Apache, PHP, MariaDB, phpMyAdmin) basée sur la box `harry-lleen/debian-13`, puis exporte la VM en OVA. L'OVA est publié dans les releases `pwnd-v*`.
