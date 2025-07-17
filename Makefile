.PHONY: ${MAKECMDGOALS}

MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR := $(dir $(MAKEFILE_PATH))

MOLECULE_SCENARIO ?= default
MOLECULE_DEBUG ?=
ANSIBLE_VERBOSITY ?= 0
DEBIAN_RELEASE ?= bookworm
UBUNTU_RELEASE ?= jammy
EL_RELEASE ?= 9
DEBIAN_SHASUMS = https://cloud.debian.org/images/cloud/${DEBIAN_RELEASE}/latest/SHA512SUMS
DEBIAN_KVM_FILENAME = $$(curl -s ${DEBIAN_SHASUMS} | grep "generic-amd64.qcow2" | awk '{print $$2}')
DEBIAN_KVM_IMAGE = https://cloud.debian.org/images/cloud/${DEBIAN_RELEASE}/latest/${DEBIAN_KVM_FILENAME}
UBUNTU_KVM_IMAGE = https://cloud-images.ubuntu.com/${UBUNTU_RELEASE}/current/${UBUNTU_RELEASE}-server-cloudimg-amd64.img
ALMA_KVM_IMAGE = https://repo.almalinux.org/almalinux/${EL_RELEASE}/cloud/x86_64/images/AlmaLinux-${EL_RELEASE}-GenericCloud-latest.x86_64.qcow2
ROCKY_KVM_IMAGE = https://dl.rockylinux.org/pub/rocky/${EL_RELEASE}/images/x86_64/Rocky-${EL_RELEASE}-GenericCloud-Base.latest.x86_64.qcow2
MOLECULE_KVM_IMAGE := $(UBUNTU_KVM_IMAGE)
GALAXY_API_KEY ?=
GITHUB_REPOSITORY ?= $$(git config --get remote.origin.url | cut -d':' -f 2 | cut -d. -f 1)
GITHUB_ORG = $$(echo ${GITHUB_REPOSITORY} | cut -d/ -f 1)
GITHUB_REPO = $$(echo ${GITHUB_REPOSITORY} | cut -d/ -f 2)
ROLE_DIR = roles
ROLE_FILE = roles.yml
COLLECTION_NAMESPACE = $$(yq '.namespace' < galaxy.yml -r)
COLLECTION_NAME = $$(yq '.name' < galaxy.yml -r)
COLLECTION_VERSION = $$(yq '.version' < galaxy.yml -r)

PURGE_ARGS ?= false
LOGIN_ARGS ?=

all: install version lint test

shell:
	devbox shell

ubuntu:
	make create prepare \
		MOLECULE_KVM_IMAGE=${UBUNTU_KVM_IMAGE} \
		MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

noble ubuntu2404:
	make ubuntu UBUNTU_RELEASE=noble MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

jammy ubuntu2204:
	make ubuntu UBUNTU_RELEASE=jammy MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

focal ubuntu2004:
	make ubuntu UBUNTU_RELEASE=focal MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

debian:
	make create prepare \
		MOLECULE_KVM_IMAGE=${DEBIAN_KVM_IMAGE} \
		MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

bookworm debian12:
	make debian MOLECULE_SCENARIO=${MOLECULE_SCENARIO} DEBIAN_RELEASE=bookworm

alma:
	make create prepare \
		MOLECULE_KVM_IMAGE=${ALMA_KVM_IMAGE} \
		MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

alma9:
	make alma EL_RELEASE=9 MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

rocky:
	make create prepare \
		MOLECULE_KVM_IMAGE=${ROCKY_KVM_IMAGE} \
		MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

rocky9:
	make rocky EL_RELEASE=9 MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

test: lint
	rm -rf ansible_collections
	ANSIBLE_COLLECTIONS_PATH=$(MAKEFILE_DIR) \
	MOLECULE_KVM_IMAGE=${MOLECULE_KVM_IMAGE} \
	uv run molecule $@ -s ${MOLECULE_SCENARIO}

install:
	@uv sync

lint: install
	uv run yamllint . -c .yamllint
	ANSIBLE_COLLECTIONS_PATH=$(MAKEFILE_DIR) \
	uv run ansible-lint -p playbooks/ --exclude "ansible_collections/*"

requirements: install
	@rm -rf ${ROLE_DIR}/*
	@python --version
	@if [ -f ${ROLE_FILE} ]; then \
		uv run ansible-galaxy role install \
			--force --no-deps \
			--roles-path ${ROLE_DIR} \
			--role-file ${ROLE_FILE}; \
	fi
	@ANSIBLE_COLLECTIONS_PATH=$(MAKEFILE_DIR) \
	uv run ansible-galaxy collection install \
		--force-with-deps .
	@\find ./ -name "*.ymle*" -delete

build: requirements
	@uv run ansible-galaxy collection build --force

ifeq (purge,$(firstword $(MAKECMDGOALS)))
	PURGE_ARGS := "true"
endif

ifeq (login,$(firstword $(MAKECMDGOALS)))
    LOGIN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(subst $(space),,$(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))):;@:)
endif

dependency create prepare converge idempotence side-effect verify destroy reset list purge login:
	rm -rf ansible_collections
	ANSIBLE_VERBOSITY=${ANSIBLE_VERBOSITY} \
	MOLECULE_DEBUG=${MOLECULE_DEBUG} \
	ANSIBLE_COLLECTIONS_PATH=$(MAKEFILE_DIR) \
	MOLECULE_KVM_IMAGE=${MOLECULE_KVM_IMAGE} \
	LIBVIRT_PURGE=$(PURGE_ARGS) \
	uv run molecule $@ -s ${MOLECULE_SCENARIO} $(LOGIN_ARGS)

ignore:
	@uv run ansible-lint --generate-ignore

clean: destroy reset
	rm -rf ansible_collections
	rm -rf libvirt
	@uv env remove $$(which python) >/dev/null 2>&1 || exit 0

publish: build
	uv run ansible-galaxy collection publish --api-key ${GALAXY_API_KEY} \
		"${COLLECTION_NAMESPACE}-${COLLECTION_NAME}-${COLLECTION_VERSION}.tar.gz"

version:
	@uv run molecule --version

debug: install version
	@uv export --dev --without-hashes || exit 0
