# Description

This lays out manual steps we performed to install a new MitkOS system on virt-manager from scratch, and version it in the MitkOS repo.

# Prerequisites

A NixOS host with Virtual Machine Manager.

# Playbook

## Download bootable ISO

Get "Minimal ISO image" from https://nixos.org/download. This was tested with https://channels.nixos.org/nixos-23.11/latest-nixos-minimal-x86_64-linux.iso

## Create && boot new virtual machine from ISO image

- Connection type QEMU / KVM
- NAT network
- Persistent storage
- 16384 ram, 4 CPU, 50 gig storage
- edit configuration before install
- Choose firmware / boot mode UEFI

Boot.

At this point it's expected you have a network connection, and don't need to start a network via `wpa-supplicant` as advised by the installer.

## Partition disk

This follows https://nixos.org/manual/nixos/unstable/index.html#sec-installation-manual-partitioning , via UEFI /GPT.


- Find what your device name is via `lsblk`. It should be a non-readonly device of type `DISK`. In our test the device is named `/dev/vda` (a `virtio`-backed disk) - we'll use this name below.

- Create partition table
```
sudo parted /dev/vda -- mklabel gpt
```

- Add the root partition, leaving 512MB for the boot partition, and space for the swap partition - in this case 8G, but fit to your neeeds.

```
sudo parted /dev/vda -- mkpart root ext4 512MB -8GB 
```

- Add the swap partition
```
parted /dev/vda -- mkpart swap linux-swap -8GB 100%
```

- Add the boot partition
```
parted /dev/vda -- mkpart ESP fat32 1MB 512MB
parted /dev/vda -- set 3 esp on
```

## Format partitions

At this point, our partitions (in the example) are
 - `/dev/vda1` - the root partition
 - `/dev/vda2` - the swap partition
 - `/dev/vda3` - the boot partition

 We need to
 - Format the root partition. We'll also associate a label named `root`
 ```
 sudo mkfs.ext4 -L root /dev/vda1
 ```
 - Format the swap partition. We'll also associate a label named `swap`
 ```
 sudo mkswap -L swap /dev/vda2
 ```

 - Format the root partition
 ```
 sudo mkfs.fat -F 32 -n boot /dev/vda3
 ```

## Mount partitions

- `sudo mount /dev/disk/by-label/root /mnt`
- `sudo mkdir -p /mnt/boot`
- `sudo mount /dev/disk/by-label/boot /mnt/boot/`
- Enable swap during install: `sudo swapon /dev/vda2`

## Installation

### Get MitkOS


On the host / build box, create a new nixos configuration for the guest.

`git checkout -B virtual-manager-install`

... then add needed corresponding changes to flake.nix, but don't provide host-specific (`hosts/foo`) config, we'll do that on guest.

```
# add stuff ... then
git add .
git commit -m "wip"
git push
```

On the guest, make sure repo can be accessed:

```
nix-shell -p git
git clone https://github.com/dimitarg/MitkOS.git
```

On the guest machine,

```
git pull
git checkout virtual-manager-install
mkdir hosts/virt-nixos # or however we named the new host in the flake
cd hosts/virt-nixos
nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

Review that hardware configuration is looking okay, and/or make any adjustments if necessary.
Specifically in this case,

- we removed all filesystems and swap device references and replaced that with an import of `standard-fs-layout.nix`


Then, (again on guest)

```
git config --global user.email "dimitar.georgiev.bg@gmail.com"
git config --global user.name "Dimitar Georgiev"
git add .
git commit
```

Finally,

```
sudo nixos-install --flake .#virt-nixos
```