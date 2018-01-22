.PHONY: base playbook packages

SHELL := bash
PACMAN_REPOS := /etc/pacman.conf.tainted
PLAYBOOK ?= user

default: playbook

base: $(PACMAN_REPOS)
	pacman -Sy --needed --noconfirm base make ansible pwgen sudo python zsh yaourt

playbook:
	ansible-playbook -v _ansible/$(PLAYBOOK).yaml

packages:
	yaourt -S --needed --noconfirm \
	base-devel xorg \
	$(shell cat _arch/packages _arch/packages.aur | grep -v '#') \
	> >(tee -a ~/yaourt.log) 2> >(tee -a ~/yaourt.err >&2)

$(PACMAN_REPOS):
	cat _arch/repos | tee -a /etc/pacman.conf
	touch $(PACMAN_REPOS)
