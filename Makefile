.PHONY: base playbook packages

SHELL := bash
PLAYBOOK ?= user

default: playbook

base:
	pacman -Sy --needed --noconfirm base make ansible pwgen sudo python zsh

playbook:
	ansible-playbook -v _ansible/$(PLAYBOOK).yaml

packages:
	paru -S --needed \
	base-devel xorg \
	$(shell cat _arch/packages _arch/packages.aur | grep -v '#') \
	> >(tee -a ~/packages.log) 2> >(tee -a ~/packages.err >&2)
