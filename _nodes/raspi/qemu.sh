#!/usr/bin/env bash

DOT=$(cd -P "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)
var="${DOT}/var"

set -ex

root_img="$var/archy.img"
arch_file="ArchLinuxARM-rpi-armv7-latest.tar.gz"

# 0. Prep
prep() {
  mkdir -p "$var"
  pushd "$var"
  wget http://os.archlinuxarm.org/os/$arch_file
  sudo pacman -Sy qemu-img qemu-system-arm
  popd
}

# 1. Image setup
create_base_image() {
  mkdir -p "$var"
  pushd "$var"

  local image="rootfs.img"
  local lodev

  # partitions
  local pcmd="sudo parted $image --script"
  fallocate -l 8G $image
  $pcmd -- mklabel msdos
  $pcmd -- mkpart primary fat32 1 128
  $pcmd -- mkpart primary ext4 128 100%
  $pcmd -- set 1 boot on
  $pcmd print

  lodev=$(sudo losetup -f --show $image)
  sudo partx -a "$lodev"

  sudo mkfs.vfat -F32 "$lodev"p1
  sudo mkfs.ext4 -F "$lodev"p2

  mkdir -p boot root boot-local || true
  sudo mount "$lodev"p1 boot
  sudo mount "$lodev"p2 root

  sudo bsdtar -xpf "$arch_file" -C root/
  sudo mv root/boot/* boot/
  sudo rsync -avP --delete boot/ boot-local/
  sudo chown -R $(id -u):$(id -g) boot-local/

  sudo cp root/etc/fstab root/etc/fstab.orig
  sudo tee root/etc/fstab > /dev/null <<'EOF'
/dev/mmcblk0p1       /boot   vfat    defaults        0       0
/dev/mmcblk0p2       /       ext4    defaults        0       0
EOF

  # ssh setup
  sudo mkdir -p root/root/.ssh
  curl https://static.getbetter.ro/karelian2.pub -o- | sudo tee root/root/.ssh/authorized_keys
  sudo sed -i -e 's/UsePAM yes/UsePAM no/g' root/etc/ssh/sshd_config

  sudo ssh-keygen -b 4096 -f root/etc/ssh/ssh_host_rsa_key -t rsa -N ""
  sudo ssh-keygen -b 1024 -f root/etc/ssh/ssh_host_dsa_key -t dsa -N ""
  sudo ssh-keygen -b 521  -f root/etc/ssh/ssh_host_ecdsa_key -t ecdsa -N ""
  sudo ssh-keygen -b 4096 -f root/etc/ssh/ssh_host_ed25519_key -t ed25519 -N ""

  # umount + convert
  sudo umount "$lodev"p1 "$lodev"p2
  sudo partx -d "$lodev"
  sudo losetup -d "$lodev"

  qemu-img convert -f raw -O qcow2 $image $root_img
  rm -f $image
  popd
}

# 2. Run Forrest
run() {
  local ssh_port=5555
  local nic
  nic="-netdev user,id=net0,hostfwd=tcp::${ssh_port}-:22 -device usb-net,netdev=net0"

  cmdline=(
    "root=/dev/mmcblk0p2 rw rootwait rootfstype=ext4"
    "earlyprintk console=ttyAMA0,115200"
    "selinux=0 plymouth.enable=0 smsc95xx.turbo_mode=N elevator=noop"
    "dwc_otg.fiq_fsm_enable=0 dwc_otg.lpm_enable=0"
    "panic=1"
  )

  qemu-system-arm \
    -nographic \
    -smp 4 \
    -kernel "$var/boot-local/kernel7.img" \
    -initrd "$var/boot-local/initramfs-linux.img" \
    -dtb "$var/boot-local/bcm2709-rpi-2-b.dtb" \
    -cpu arm1176 -m 1024 -M raspi2b -serial mon:stdio \
    -append "${cmdline[*]}" -hda $root_img \
    $nic
}

"$@"
