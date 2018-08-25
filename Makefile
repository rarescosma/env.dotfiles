.PHONY: base playbook packages

SHELL := bash
PACMAN_REPOS := /etc/pacman.conf.tainted
PLAYBOOK ?= user

default: playbook

base: $(PACMAN_REPOS)
	pacman -Sy --needed --noconfirm base make ansible pwgen sudo python zsh trizen

playbook:
	ansible-playbook -v _ansible/$(PLAYBOOK).yaml

packages:
	trizen -S --needed --noconfirm \
	base-devel xorg \
	$(shell cat _arch/packages _arch/packages.aur | grep -v '#') \
	> >(tee -a ~/packages.log) 2> >(tee -a ~/packages.err >&2)

$(PACMAN_REPOS):
	cat _arch/repos | tee -a /etc/pacman.conf
	touch $(PACMAN_REPOS)
