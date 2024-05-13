.PHONY: ${MAKECMDGOALS}

MOLECULE_SCENARIO ?= default
DEBIAN_RELEASE ?= bookworm
UBUNTU_RELEASE ?= jammy
EL_RELEASE ?= 9
DEBIAN_SHASUMS = https://cloud.debian.org/images/cloud/${DEBIAN_RELEASE}/latest/SHA512SUMS
DEBIAN_KVM_FILENAME = $$(curl -s ${DEBIAN_SHASUMS} | grep "generic-amd64.qcow2" | awk '{print $$2}')
DEBIAN_KVM_IMAGE = https://cloud.debian.org/images/cloud/${DEBIAN_RELEASE}/latest/${DEBIAN_KVM_FILENAME}
UBUNTU_KVM_IMAGE = https://cloud-images.ubuntu.com/${UBUNTU_RELEASE}/current/${UBUNTU_RELEASE}-server-cloudimg-amd64.img
ALMA_KVM_IMAGE = https://repo.almalinux.org/almalinux/${EL_RELEASE}/cloud/x86_64/images/AlmaLinux-${EL_RELEASE}-GenericCloud-latest.x86_64.qcow2
ROCKY_KVM_IMAGE = https://dl.rockylinux.org/pub/rocky/${EL_RELEASE}/images/x86_64/Rocky-${EL_RELEASE}-GenericCloud-Base.latest.x86_64.qcow2
MOLECULE_OS_RELEASE := $(UBUNTU_RELEASE)
MOLECULE_KVM_IMAGE := $(UBUNTU_KVM_IMAGE)
GALAXY_API_KEY ?=
GITHUB_REPOSITORY ?= $$(git config --get remote.origin.url | cut -d: -f 2 | cut -d. -f 1)
GITHUB_ORG = $$(echo ${GITHUB_REPOSITORY} | cut -d/ -f 1)
GITHUB_REPO = $$(echo ${GITHUB_REPOSITORY} | cut -d/ -f 2)
REQUIREMENTS = requirements.yml
ROLE_DIR = roles
ROLE_FILE = roles.yml
COLLECTION_NAMESPACE = $$(yq '.namespace' < galaxy.yml)
COLLECTION_NAME = $$(yq '.name' < galaxy.yml)
COLLECTION_VERSION = $$(yq '.version' < galaxy.yml)

all: install version lint test

ubuntu:
	make create prepare verify \
		MOLECULE_KVM_IMAGE=${UBUNTU_KVM_IMAGE} \
		MOLECULE_SCENARIO=${MOLECULE_SCENARIO} \
		MOLECULE_OS_RELEASE=${UBUNTU_RELEASE}

noble ubuntu2404:
	make ubuntu UBUNTU_RELEASE=noble MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

jammy ubuntu2204:
	make ubuntu UBUNTU_RELEASE=jammy MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

focal ubuntu2004:
	make ubuntu UBUNTU_RELEASE=focal MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

debian:
	make create prepare verify \
		MOLECULE_KVM_IMAGE=${DEBIAN_KVM_IMAGE} \
		MOLECULE_SCENARIO=${MOLECULE_SCENARIO} \
		MOLECULE_OS_RELEASE=${DEBIAN_RELEASE}

bookworm debian12:
	make debian MOLECULE_SCENARIO=${MOLECULE_SCENARIO} DEBIAN_RELEASE=bookworm

alma:
	make create prepare verify \
		MOLECULE_KVM_IMAGE=${ALMA_KVM_IMAGE} \
		MOLECULE_SCENARIO=${MOLECULE_SCENARIO} \
		MOLECULE_OS_RELEASE=alma${EL_RELEASE}

alma8:
	make alma EL_RELEASE=8 MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

alma9:
	make alma EL_RELEASE=9 MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

rocky:
	make create prepare verify \
		MOLECULE_KVM_IMAGE=${ROCKY_KVM_IMAGE} \
		MOLECULE_SCENARIO=${MOLECULE_SCENARIO}
		MOLECULE_OS_RELEASE=rocky${EL_RELEASE}

rocky8:
	make rocky EL_RELEASE=8 MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

rocky9:
	make rocky EL_RELEASE=9 MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

test: lint
	MOLECULE_KVM_IMAGE=${MOLECULE_KVM_IMAGE} \
	poetry run molecule $@ -s ${MOLECULE_SCENARIO}

install:
	@type poetry >/dev/null || pip3 install poetry
	@type yq || sudo apt-get install -y yq
	@type expect || sudo apt-get install -y expect
	@type nmcli || sudo apt-get install -y network-manager
	@sudo apt-get install -y libvirt-dev xfsprogs
	@poetry install --no-root

lint: install
	poetry run yamllint .

requirements: install
	@rm -rf ${ROLE_DIR}/*
	@python --version
	@if [ -f ${ROLE_FILE} ]; then \
		poetry run ansible-galaxy role install \
			--force --no-deps \
			--roles-path ${ROLE_DIR} \
			--role-file ${ROLE_FILE}; \
	fi
	@poetry run ansible-galaxy collection install \
		--force-with-deps .
	@\find ./ -name "*.ymle*" -delete

build: requirements
	@poetry run ansible-galaxy collection build --force

dependency create prepare converge idempotence side-effect verify destroy login reset list:
	echo MOLECULE_KVM_IMAGE=${MOLECULE_KVM_IMAGE}; \
	MOLECULE_KVM_IMAGE=${MOLECULE_KVM_IMAGE} \
	MOLECULE_OS_RELEASE=${MOLECULE_OS_RELEASE} \
	poetry run molecule $@ -s ${MOLECULE_SCENARIO}

purge:
	MOLECULE_KVM_IMAGE=${MOLECULE_KVM_IMAGE} \
	LIBVIRT_PURGE=false \
	poetry run molecule $@ -s ${MOLECULE_SCENARIO}

ignore:
	@poetry run ansible-lint --generate-ignore

clean: destroy reset
	@poetry env remove $$(which python) >/dev/null 2>&1 || exit 0

publish: build
	poetry run ansible-galaxy collection publish --api-key ${GALAXY_API_KEY} \
		"${COLLECTION_NAMESPACE}-${COLLECTION_NAME}-${COLLECTION_VERSION}.tar.gz"

version:
	@poetry run molecule --version

debug: version
	@poetry export --dev --without-hashes
