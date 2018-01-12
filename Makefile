.PHONY: arch debian arch-packages debian-packages install

PACMAN_REPOS := /etc/pacman.conf.tainted

default: arch
arch: arch-packages install
debian: debian-packages install

arch-packages: $(PACMAN_REPOS)
	sudo pacman -S --noconfirm yaourt ansible
	#yaourt -S --needed --noconfirm `cat _arch/package.groups`
	yaourt -S --needed --noconfirm `cat _arch/packages`

$(PACMAN_REPOS):
	cat _arch/repos | sudo tee -a /etc/pacman.conf
	sudo touch $(PACMAN_REPOS)

debian-packages:
	sudo apt-get update
	sudo apt-get dist-upgrade -y
	sudo apt-get install -y `cat _debian/packages`

install:
	ansible-playbook _ansible/install.yaml
