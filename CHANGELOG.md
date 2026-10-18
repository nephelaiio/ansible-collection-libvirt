# Changelog

## 0.6.0

- Support Ubuntu 26.04 KVM hosts: install `qemu-system-x86` and `qemu-utils` instead of the `qemu-kvm` virtual package
- Remove the unused `qemu-efi-aarch64` firmware package
- Use the unversioned `q35` machine type instead of the deprecated `pc-q35-6.2`
- Test on Ubuntu 24.04 and 26.04 KVM hosts; drop Ubuntu 20.04 guests, which ansible-core 2.20+ no longer supports
