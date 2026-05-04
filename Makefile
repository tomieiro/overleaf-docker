# Makefile

UBUNTU_MIRROR ?= http://br.archive.ubuntu.com/ubuntu
NVM_VERSION ?= v0.40.3
NODE_VERSION ?= node
TEXLIVE_MIRROR ?= http://mirror.ctan.org/systems/texlive/tlnet


build-base:
	docker build \
		--build-arg UBUNTU_MIRROR=$(UBUNTU_MIRROR) \
		--build-arg NVM_VERSION=$(NVM_VERSION) \
		--build-arg NODE_VERSION=$(NODE_VERSION) \
		--build-arg TEXLIVE_MIRROR=$(TEXLIVE_MIRROR) \
		-f Dockerfile-base \
		-t sharelatex/sharelatex-base .


build-community:
	docker build -f Dockerfile -t sharelatex/sharelatex .


.PHONY: build-base build-community
