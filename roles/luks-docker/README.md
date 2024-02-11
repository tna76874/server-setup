# Ansible Role: LUKS Mount State with docker-compose restart

This Ansible role automates the setup of LUKS (Linux Unified Key Setup) encryption on a device and handles the mounting and unmounting of the encrypted container including associated docker-compose states.

## Description

This role ensures that the necessary packages are installed, both via apt and pip, to support LUKS encryption and Python-based operations. It checks the existence of the LUKS mapper device and whether the mount path is already mounted. If not, it opens the LUKS device, triggers the shutdown of Docker-compose services if needed, mounts the LUKS container to the specified mount path, and finally closes the LUKS device after unmounting.

## Initialization of the LUKS Volume

Before using this role, carefully create the LUKS volume, e.g. like from this source: [https://wiki.ubuntuusers.de/LUKS/Containerdatei/](https://wiki.ubuntuusers.de/LUKS/Containerdatei/)

## Role Variables

This role expects the following variables to be defined:

- `luks_mapper_device`: The name of the LUKS mapper device. Use something unique, that is clearly associated with your container.
- `luks_container`: The path to the LUKS container, as created in the section 'initialization'.
- `luks_password`: The passphrase for unlocking the LUKS container.
- `luks_mount_path`: The path where the LUKS container will be mounted.
- `luks_mount_state`: Boolean indicating whether the LUKS container should be mounted or not. Default: True
- `luks_docker_services`: A list of the paths to docker-compose folders (not the compose-file itselt!). It will be ensured, that these services are running, respective not running, corresponding to the  `luks_mount_state`. Default: []

## Example Playbook

```yaml
- hosts: myserver
  vars:
    luks_mapper_device: my_mapper_device
    luks_container: /mycontainers/luksvolume
    luks_password: my_passphrase
    luks_mount_path: /mnt/encrypted
    luks_mount_state: true   
  roles:
    - role: luks-docker
