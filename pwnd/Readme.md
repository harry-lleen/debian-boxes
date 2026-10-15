# Projet S6 PWND

Les fichiers pour la mise en place de la VM Virtualbox pour le module PWND du semestre 6

## Les pré-requis

### Les ressources informatiques

Pour faire fonctionner ce Labs il faut prévoir au moins 2 CPU /coeurs et 4Go de Ram (8Go est plus judicieux). L'espace disque est de l'ordre des 8 Go.
La virtualisation doit être activée sur le PC hôte (machine physique )
<https://support.bluestacks.com/hc/fr-fr/articles/115003174386-Comment-puis-je-activer-la-virtualisation-VT-sur-mon-PC->

### Les applications obligatoires

* Oracle Virtualbox (<https://www.virtualbox.org/wiki/Downloads>)
* Oracle VM VirtualBox Extension Pack (adapté à la version de virtualbox installée précédement)
* HashiCorp Vagrant (<https://www.vagrantup.com/>)

### Les fichiers obligatoires

* choisir le zip en haut à gauche
* cloner avec git (en haut à gauche)

Vous trouverez les reperoires/fichiers :

* ./Vagrantfile : qui contient l'ensemble des déclarations pour la construction du Labs
* scripts/install_sys.sh : mise en place des configurations de base sur toutes les VMs
* scripts/install_bdd.sh : Mise en place de la base de données mysql
* scripts/install_myadmin.sh : Mise en place de l'application PhpMyAdmin
* scripts/install_web.sh : Mise en place du serveur Apache2

## Description du Labs

Le labs est constitué de 1 machine virtuelle Virtualbox basé sur la box fr-book-64 (Debian 12 - AMD64)
Cette machine est reliée à votre machine réelle par un réseau privé hôte via l'adresse 192.168.56.80
La base de données MariaDB est accèssible depuis l'hôte.

* L'application PhpMyAdmin est accéssible par l'adresse <http://192.168.56.80/myadmin>

## Utilisation des commandes vagrant

Télécharger la box modèle
    ```vagrant box add chavinje/fr-book-64```

Activer une VM uniquement (srv-web par exemple)
    ```vagrant up srv-web```

Se connecter à une VM (firewall par exemple)
    ```vagrant ssh firewall```

Arréter une VM (victime par exemple)
    ```vagrant halt victime```

Détruire toutes les VMs (sans demande de confirmation)
    ```vagrant destroy -f```

## Utiliser l'OVA (Mac Apple Silicon)

La box fr-book-64 n'existe qu'en amd64 : sur un Mac Apple Silicon, on utilise l'OVA `srv-irdw-debian13-arm64-<version>.ova` (Debian 13 arm64), publiée dans les releases `pwnd-v*` du dépôt.

1. Installer VirtualBox 7.1 ou plus récent (pas besoin de Vagrant).
2. Fichier › Importer un appareil virtuel… › choisir l'OVA.
3. Démarrer la VM `srv-irdw`.
4. Si VirtualBox affiche « Nonexistent host-only network » : Fichier › Outils › Gestionnaire de réseau › Réseaux hôte uniquement › Créer (masque 255.255.255.0, borne inférieure 192.168.56.1, borne supérieure 192.168.56.254), puis dans Configuration › Réseau › Carte 2 de la VM, sélectionner ce réseau.
5. phpMyAdmin : <http://192.168.56.80/myadmin>, compte `irdw` / `network` (aussi pour SSH : `ssh irdw@192.168.56.80`).

Fabriquer l'OVA (sur un Mac Apple Silicon avec Vagrant) :

    vagrant up
    ./export-ova.sh 1.0.0

`export-ova.sh` supprime l'utilisateur vagrant et le dossier partagé, puis écrit l'OVA et son sha256 dans `build/`. Supprimer ensuite la VM avec `vagrant destroy -f`.
