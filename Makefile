include .devbox/virtenv/pokerops.ansible-utils.molecule/Makefile

DEBIAN_RELEASE ?= bookworm
UBUNTU_RELEASE ?= noble
EL_RELEASE ?= 9
DEBIAN_SHASUMS = https://cloud.debian.org/images/cloud/${DEBIAN_RELEASE}/latest/SHA512SUMS
DEBIAN_KVM_FILENAME = $$(curl -s ${DEBIAN_SHASUMS} | grep "generic-amd64.qcow2" | awk '{print $$2}')
DEBIAN_KVM_IMAGE = https://cloud.debian.org/images/cloud/${DEBIAN_RELEASE}/latest/${DEBIAN_KVM_FILENAME}
UBUNTU_KVM_IMAGE = https://cloud-images.ubuntu.com/${UBUNTU_RELEASE}/current/${UBUNTU_RELEASE}-server-cloudimg-amd64.img
ALMA_KVM_IMAGE = https://repo.almalinux.org/almalinux/${EL_RELEASE}/cloud/x86_64/images/AlmaLinux-${EL_RELEASE}-GenericCloud-latest.x86_64.qcow2
ROCKY_KVM_IMAGE = https://dl.rockylinux.org/pub/rocky/${EL_RELEASE}/images/x86_64/Rocky-${EL_RELEASE}-GenericCloud-Base.latest.x86_64.qcow2
MOLECULE_KVM_IMAGE := $(UBUNTU_KVM_IMAGE)

ubuntu:
	make test \
		MOLECULE_KVM_IMAGE=${UBUNTU_KVM_IMAGE} \
		MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

noble ubuntu2404:
	make ubuntu UBUNTU_RELEASE=noble MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

jammy ubuntu2204:
	make ubuntu UBUNTU_RELEASE=jammy MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

focal ubuntu2004:
	make ubuntu UBUNTU_RELEASE=focal MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

debian:
	make test \
		MOLECULE_KVM_IMAGE=${DEBIAN_KVM_IMAGE} \
		MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

bookworm debian12:
	make debian MOLECULE_SCENARIO=${MOLECULE_SCENARIO} DEBIAN_RELEASE=bookworm

alma:
	make test \
		MOLECULE_KVM_IMAGE=${ALMA_KVM_IMAGE} \
		MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

alma9:
	make alma EL_RELEASE=9 MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

rocky:
	make test \
		MOLECULE_KVM_IMAGE=${ROCKY_KVM_IMAGE} \
		MOLECULE_SCENARIO=${MOLECULE_SCENARIO}

rocky9:
	make rocky EL_RELEASE=9 MOLECULE_SCENARIO=${MOLECULE_SCENARIO}
