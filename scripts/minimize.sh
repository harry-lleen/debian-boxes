#!/bin/sh -eux
# Remplit l'espace libre de zéros pour aider l'export VMDK.

for fs in $(df --output=target -t ext4 | tail -n +2); do
  dd if=/dev/zero of="$fs/.zero" bs=1M status=none || true  # s'arrête sur « disque plein », c'est voulu
  rm -f "$fs/.zero"
done

swap=$(blkid -t TYPE=swap -o device | head -n1 || true)
if [ -n "$swap" ]; then
  uuid=$(blkid -s UUID -o value "$swap")
  swapoff "$swap" || true
  dd if=/dev/zero of="$swap" bs=1M status=none || true
  mkswap -U "$uuid" "$swap"
fi

sync
