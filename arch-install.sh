#!/bin/bash
#
# Arch Linux installation
#
# Bootable USB:
# - [Download](https://archlinux.org/download/) ISO and GPG files
# - Verify the ISO file: `$ pacman-key -v archlinux-<version>-dual.iso.sig`
# - Create a bootable USB with: `# dd if=archlinux*.iso of=/dev/sdX && sync`
#
# UEFI setup:
#
# - Set boot mode to UEFI, disable Legacy mode entirely.
# - Temporarily disable Secure Boot.
# - Make sure a strong UEFI administrator password is set.
# - Delete preloaded OEM keys for Secure Boot, allow custom ones.
# - Set SATA operation to AHCI mode.
#
# Run installation:
#
# - Connect to wifi via: `# iwctl station wlan0 connect WIFI-NETWORK`
# - Run: `# bash <(curl -sL https://git.io/karelian-arch)`

set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

exec 1> >(tee "/tmp/stdout.log")
exec 2> >(tee "/tmp/stderr.log" >&2)

export SNAP_PAC_SKIP=y

# Dialog
BACKTITLE="Arch Linux installation"

get_input() {
    title="$1"
    description="$2"

    input=$(dialog --clear --stdout --backtitle "$BACKTITLE" --title "$title" --inputbox "$description" 0 0)
    echo "$input"
}

get_password() {
    title="$1"
    description="$2"

    init_pass=$(dialog --clear --stdout --backtitle "$BACKTITLE" --title "$title" --passwordbox "$description" 0 0)
    : ${init_pass:?"password cannot be empty"}

    test_pass=$(dialog --clear --stdout --backtitle "$BACKTITLE" --title "$title" --passwordbox "$description again" 0 0)
    if [[ "$init_pass" != "$test_pass" ]]; then
        echo "Passwords did not match" >&2
        exit 1
    fi
    echo $init_pass
}

get_choice() {
    title="$1"
    description="$2"
    shift 2
    options=("$@")
    dialog --clear --stdout --backtitle "$BACKTITLE" --title "$title" --menu "$description" 0 0 0 "${options[@]}"
}

echo -e "\n### Checking UEFI boot mode"
if [ ! -f /sys/firmware/efi/fw_platform_size ]; then
    echo >&2 "You must boot in UEFI mode to continue"
    exit 2
fi

echo -e "\n### Setting up clock"
timedatectl set-ntp true
hwclock --systohc --utc

echo -e "\n### Installing additional tools"
pacman -Sy --noconfirm --needed git reflector terminus-font dialog wget

hostname=$(get_input "Hostname" "Enter hostname") || exit 1
clear
: ${hostname:?"hostname cannot be empty"}

user=$(get_input "User" "Enter username") || exit 1
clear
: ${user:?"user cannot be empty"}

password=$(get_password "User" "Enter password") || exit 1
clear
: ${password:?"password cannot be empty"}

devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac | tr '\n' ' ')
read -r -a devicelist <<< $devicelist

device=$(get_choice "Installation" "Select installation disk" "${devicelist[@]}") || exit 1
clear


echo -e "\n### Setting up fastest mirrors"
mirrorlist="/etc/pacman.d/mirrorlist"
reflector -c Sweden --latest 30 --sort rate --save "$mirrorlist"

echo -e "\n### Prepending flexo mirror"
echo -e "Server = http://192.168.122.1:7878/\$repo/os/\$arch\n$(cat "$mirrorlist")" > "$mirrorlist"

echo -e "\n### Setting up partitions"
umount -R /mnt 2> /dev/null || true

lsblk -plnx size -o name "${device}" | xargs -n1 wipefs --all
sgdisk --clear "${device}" --new 1::-551MiB "${device}" --new 2::0 --typecode 2:ef00 "${device}"
sgdisk --change-name=1:primary --change-name=2:ESP "${device}"

part_root="$(ls ${device}* | grep -E "^${device}p?1$")"
part_boot="$(ls ${device}* | grep -E "^${device}p?2$")"

echo -e "\n### Formatting partitions"
mkfs.vfat -n "EFI" -F 32 "${part_boot}"
mkfs.btrfs -L btrfs "${part_root}"

echo -e "\n### Setting up BTRFS subvolumes"
mount "${part_root}" /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/docker
btrfs subvolume create /mnt/logs
btrfs subvolume create /mnt/temp
btrfs subvolume create /mnt/swap
btrfs subvolume create /mnt/snapshots
umount /mnt

mount -o noatime,nodiratime,compress=zstd,subvol=root "${part_root}" /mnt
mkdir -p /mnt/{mnt/btrfs-root,efi,home,var/{lib/docker,log,tmp},swap,.snapshots}
mount "${part_boot}" /mnt/efi
mount -o noatime,nodiratime,compress=zstd,subvol=/ "${part_root}" /mnt/mnt/btrfs-root
mount -o noatime,nodiratime,compress=zstd,subvol=home "${part_root}" /mnt/home
mount -o noatime,nodiratime,compress=zstd,subvol=docker "${part_root}" /mnt/var/lib/docker
mount -o noatime,nodiratime,compress=zstd,subvol=logs "${part_root}" /mnt/var/log
mount -o noatime,nodiratime,compress=zstd,subvol=temp "${part_root}" /mnt/var/tmp
mount -o noatime,nodiratime,compress=zstd,subvol=swap "${part_root}" /mnt/swap
mount -o noatime,nodiratime,compress=zstd,subvol=snapshots "${part_root}" /mnt/.snapshots

echo -e "\n### Installing packages"
pacstrap -i /mnt base linux linux-firmware linux-headers intel-ucode \
  base-devel zsh neovim git stow dialog \
  grub efibootmgr \
  networkmanager network-manager-applet \
  mtools dosfstools btrfs-progs inetutils \
  reflector

genfstab -L /mnt >> /mnt/etc/fstab
echo "${hostname}" > /mnt/etc/hostname
echo "en_US.UTF-8 UTF-8" >> /mnt/etc/locale.gen
ln -sf /usr/share/zoneinfo/Europe/Stockholm /mnt/etc/localtime
arch-chroot /mnt locale-gen
cat << EOF > /mnt/etc/mkinitcpio.conf
MODULES=()
BINARIES=()
FILES=()
HOOKS=(base consolefont udev autodetect modconf block filesystems keyboard)
EOF
arch-chroot /mnt mkinitcpio -p linux

echo -e "\n### Configuring swap file"
truncate -s 0 /mnt/swap/swapfile
chattr +C /mnt/swap/swapfile
btrfs property set /mnt/swap/swapfile compression none
dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count=2048
chmod 600 /mnt/swap/swapfile
mkswap /mnt/swap/swapfile
echo "/swap/swapfile none swap defaults 0 0" >> /mnt/etc/fstab

echo -e "\n### Installing grub"
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

echo -e "\n### Creating user"
arch-chroot /mnt useradd -m -s /usr/bin/zsh "$user"
for group in wheel network nzbget video input; do
    arch-chroot /mnt groupadd -rf "$group"
    arch-chroot /mnt gpasswd -a "$user" "$group"
done
arch-chroot /mnt chsh -s /usr/bin/zsh
echo "$user:$password" | arch-chroot /mnt chpasswd
arch-chroot /mnt passwd -dl root

if [ "${user}" = "karelian" ]; then
    echo -e "\n### Cloning dotfiles"
    arch-chroot /mnt rm -rf "/home/$user/src/env.dotfiles"
    arch-chroot /mnt sudo -u $user mkdir -p "/home/$user/src/env.dotfiles"
    arch-chroot /mnt sudo -u $user bash -c 'git clone https://github.com/rarescosma/env.dotfiles.git /home/karelian/src/env.dotfiles'

    echo -e "\n### Running initial setup"
    arch-chroot /mnt /home/$user/src/env.dotfiles/setup-system.sh
    arch-chroot /mnt sudo -u $user /home/$user/src/env.dotfiles/setup-user.sh
    arch-chroot /mnt sudo -u $user zsh -ic true

    echo -e "\n### DONE - re-run both setup-*.sh scripts after reboot"
fi

echo -e "\n### Power off - remember to remove the installation media!"
umount -R /mnt
