import '.devbox/virtenv/pokerops.ansible-utils.molecule/justfile'

DEBIAN_RELEASE := env_var_or_default("DEBIAN_RELEASE", "bookworm")
EL_RELEASE := env_var_or_default("EL_RELEASE", "10")

ubuntu release=UBUNTU_RELEASE:
    MOLECULE_KVM_IMAGE="https://cloud-images.ubuntu.com/{{release}}/current/{{release}}-server-cloudimg-amd64.img" \
        {{just_executable()}} --justfile {{justfile()}} test

resolute: (ubuntu "resolute")
noble: (ubuntu "noble")
jammy: (ubuntu "jammy")
focal: (ubuntu "focal")

alias ubuntu2604 := resolute
alias ubuntu2404 := noble
alias ubuntu2204 := jammy
alias ubuntu2004 := focal

debian release=DEBIAN_RELEASE:
    #!/usr/bin/env bash
    set -euo pipefail
    DEBIAN_URL="https://cloud.debian.org/images/cloud/{{release}}/latest"
    DEBIAN_FILENAME=$(curl -fsSL "${DEBIAN_URL}/SHA512SUMS" | grep "generic-amd64.qcow2" | awk '{print $2}')
    MOLECULE_KVM_IMAGE="${DEBIAN_URL}/${DEBIAN_FILENAME}" \
        {{just_executable()}} --justfile {{justfile()}} test

bookworm: (debian "bookworm")
trixie: (debian "trixie")

alias debian12 := bookworm
alias debian13 := trixie

alma release=EL_RELEASE:
    MOLECULE_KVM_IMAGE="https://repo.almalinux.org/almalinux/{{release}}/cloud/x86_64/images/AlmaLinux-{{release}}-GenericCloud-latest.x86_64.qcow2" \
        {{just_executable()}} --justfile {{justfile()}} test

alma10: (alma "10")

rocky release=EL_RELEASE:
    MOLECULE_KVM_IMAGE="https://dl.rockylinux.org/pub/rocky/{{release}}/images/x86_64/Rocky-{{release}}-GenericCloud-Base.latest.x86_64.qcow2" \
        {{just_executable()}} --justfile {{justfile()}} test

rocky10: (rocky "10")
