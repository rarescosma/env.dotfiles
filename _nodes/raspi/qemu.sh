#!/bin/bash

set -ex

QCOW_IMAGE='Arch-qcow.img'
KERNEL_VER='kernel-qemu-4.4.34-jessie'

# 0. Prep
prep() {
  wget https://github.com/dhruvvyas90/qemu-rpi-kernel/raw/master/$KERNEL_VER
  wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
}

# 1. Image setup
create_base_image() {
  local image='Arch.img'
  local lodev

  fallocate -l 8G $image
  # pv --timer --rate --stop-at-size -s 8589934592 /dev/zero > $image
  fdisk $image  # 100Mb for boot, the rest for the system
  lodev=$(sudo losetup -f --show $image)
  sudo partx -a "$lodev"

  sudo mkfs.vfat "$lodev"p1
  sudo mkfs.ext4 "$lodev"p2

  mkdir boot root || true
  sudo mount /dev/loop0p1 boot
  sudo mount /dev/loop0p2 root

  sudo bsdtar -xpf ArchLinuxARM-rpi-latest.tar.gz -C root/
  sudo mv root/boot/* boot/

  sudo cp root/etc/fstab root/etc/fstab.orig
  sudo tee root/etc/fstab > /dev/null <<'EOF'
/dev/sda1       /boot   vfat    defaults        0       0
/dev/sda2       /       ext4    defaults        0       0
EOF
  sudo umount "$lodev"p1 "$lodev"p2
  sudo partx -d "$lodev"
  sudo losetup -d "$lodev"

  qemu-img convert -f raw -O qcow2 $image $QCOW_IMAGE
}

# 2. Run Forrest
run() {
  local ssh_port=5555

  qemu-system-arm \
    -kernel $KERNEL_VER \
    -cpu arm1176 -m 256 -M versatilepb -serial stdio \
    -append "root=/dev/sda2 rootfstype=ext4 rw" -hda $QCOW_IMAGE \
    -net nic,macaddr=de:ad:be:ef:ca:fe \
    -net user,hostfwd=tcp::${ssh_port}-:22
}

"$@"
