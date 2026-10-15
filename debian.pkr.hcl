packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/virtualbox"
    }
    vagrant = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

variable "debian_version" {
  type        = string
  description = "Version de l'ISO (par ex. 13.7.0)"
}

variable "iso_url" {
  type = string
}

variable "iso_checksum" {
  type = string
}

# Debian 11 n'est plus que sur archive.debian.org (fin du LTS)
variable "mirror" {
  type    = string
  default = "deb.debian.org"
}

variable "security_host" {
  type    = string
  default = "security.debian.org"
}

locals {
  major = split(".", var.debian_version)[0]
  name  = "debian-${local.major}-arm64"
}

source "virtualbox-iso" "debian" {
  vm_name              = local.name
  guest_os_type        = "Debian${local.major}_arm64"
  firmware             = "efi"
  chipset              = "armv8virtual"
  cpus                 = 2
  memory               = 2048
  disk_size            = 20480
  hard_drive_interface = "virtio"
  iso_interface        = "virtio"
  iso_url              = var.iso_url
  iso_checksum         = var.iso_checksum
  headless             = true
  rtc_time_base        = "UTC"
  gfx_controller       = "qemuramfb"
  gfx_vram_size        = 16

  http_directory = "http"
  boot_wait      = "10s"

  boot_command = [
    "<wait>e<wait><down><down><down><end><left><left><left><left><left><left><left><left><left><left>",
    " auto=true priority=critical preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg",
    " netcfg/get_hostname=${local.name} netcfg/get_domain=localdomain",
    " mirror/http/hostname=${var.mirror} apt-setup/security_host=${var.security_host}<f10>"
  ]

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--audio-enabled", "off"],
    ["modifyvm", "{{.Name}}", "--usb-xhci", "on"],
    ["modifyvm", "{{.Name}}", "--mouse", "usb"],
    ["modifyvm", "{{.Name}}", "--keyboard", "usb"],
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
    ["storagectl", "{{.Name}}", "--name", "IDE", "--remove"],
  ]

  guest_additions_mode = "upload"
  guest_additions_path = "/tmp/VBoxGuestAdditions.iso"

  communicator     = "ssh"
  ssh_username     = "vagrant"
  ssh_password     = "vagrant"
  ssh_timeout      = "60m"
  shutdown_command = "sudo systemctl poweroff"
  output_directory = "output/${local.name}"
}

build {
  sources = ["source.virtualbox-iso.debian"]

  provisioner "file" {
    source      = "http/vagrant.pub"
    destination = "/tmp/vagrant.pub"
  }

  provisioner "shell" {
    execute_command = "sudo -E sh -eux '{{ .Path }}'"
    scripts         = ["scripts/provision.sh", "scripts/minimize.sh"]
  }

  post-processor "vagrant" {
    compression_level = 9
    output            = "build/${local.name}-${var.debian_version}.virtualbox.box"
  }
}
