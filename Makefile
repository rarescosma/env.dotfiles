SHELL := bash
ARCH ?= x86_64
PARU_VER := 1.11.2
PARU_RELEASE := paru-v$(PARU_VER)-$(ARCH).tar.zst

all: help

/usr/bin/paru:
	curl -sL https://github.com/Morganamilo/paru/releases/download/v$(PARU_VER)/$(PARU_RELEASE) -O
	tar -xvf $(PARU_RELEASE) paru
	mv paru /usr/bin/paru
	rm $(PARU_RELEASE)

.PHONY: packages
packages: /usr/bin/paru ## Install arch packages
	paru -Sy --needed base-devel xorg \
	$(shell cat _arch/packages | grep -v '#')

.PHONY: aur
aur: /usr/bin/paru ## Install AUR packages
	paru -Syu --needed --noconfirm --pgpfetch \
	$(shell cat _arch/packages.aur | grep -v '#')

.PHONY: help
help: ## This help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
