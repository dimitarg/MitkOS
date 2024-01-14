# Description

This lays out manual steps we performed to install a new MitkOS system on virt-manager from scratch, and version it in the MitkOS repo.

# Prerequisites

A NixOS host with Virtual Machine Manager.

# Playbook

## Download bootable ISO

Get "Graphical ISO image" from https://nixos.org/download.
## Create && boot new virtual machine from ISO image

- Connection type QEMU / KVM
- NAT network
- Persistent storage
- 16384 ram, 4 CPU, 100 gig storage
- edit configuration before install
- Choose firmware / boot mode UEFI

Boot.

At this point it's expected you have a network connection, and don't need to start a network via `wpa-supplicant` as advised by the installer.

## Installer
next -> next -> finish, specify username pass etc, specify standard partitioning scheme, no encryption for now.

Reboot by finishing installer.

## Post-install

```
nix-shell -p git
git clone https://github.com/dimitarg/MitkOS.git
cd MitkOS
mkdir hosts/virt-nixos
cp /etc/nixos/hardware-configuration.nix hosts/nixos
git checkout -b virtual-manager-easy
git config --global user.email "dimitar.georgiev.bg@gmail.com"
git config --global user.name "Dimitar Georgiev"
git add .
git commit
```

and

```
sudo nixos-rebuild switch --flake .#virt-nixos
```