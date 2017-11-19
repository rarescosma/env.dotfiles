.PHONY: arch debian arch-packages debian-packages

PACKMAN_REPOS := /etc/pacman.conf.tainted

default: arch
arch: arch-packages link-config set-shell
debian: debian-packages link-config set-shell

arch-packages: $(PACMAN_REPOS)
	sudo pacman -Sy yaourt termite infinality-bundle
	yaourt -S --needed --noconfirm `cat .arch/packages`

$(PACMAN_REPOS):
	cat .arch/repos | sudo tee -a /etc/pacman.conf
	touch $(PACMAN_REPOS)

debian-packages:
	sudo apt-get update
	sudo apt-get dist-upgrade -y
	sudo apt-get install -y `cat .debian/packages`

link-config:
	stow -t ~ --restow `ls -d */`

set-shell:
	chsh -s `which zsh`
