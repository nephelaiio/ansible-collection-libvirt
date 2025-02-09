# Ansible Collection - nephelaiio.libvirt

[![Build Status](https://github.com/nephelaiio/ansible-collection-libvirt/actions/workflows/libvirt.yml/badge.svg)](https://github.com/nephelaiio/ansible-collection-libvirt/actions/wofklows/libvirt.yml)
[![Ansible Galaxy](http://img.shields.io/badge/ansible--galaxy-nephelaiio.libvirt-blue.svg)](https://galaxy.ansible.com/ui/repo/published/nephelaiio/libvirt/)

An [ansible collection](https://galaxy.ansible.com/ui/repo/published/nephelaiio/libvirt/) to create local [Libvirt](https://libvirt.org/) vm guests

## Collection hostgroups

| Hostgroup      |     Default | Description                  |
| :------------- | ----------: | :--------------------------- |
| libvirt_hosts  | 'localhost' | Libvirt virtualization hosts |
| libvirt_guests |       'all' | Libvirt guests               |

## Collection variables

The following is the list of parameters intended for end-user manipulation:

| Parameter            |                                  Default | Description                    | Required |
| :------------------- | ---------------------------------------: | :----------------------------- | :------- |
| libvirt_platforms    |                      [<platform_object>] | Libvirt guest list             | true     |
| libvirt_address      |                        '172.31.252.1/24' | Libvirt host address           | false    |
| libvirt_network      |                               'molecule' | Libvirt network name           | false    |
| libvirt_resolvers    |                   ['1.1.1.1', '8.8.8.8'] | Libvirt network resolvers      | false    |
| libvirt_user         |                               'molecule' | OS user for guest access       | false    |
| libvirt_pass         |                               'molecule' | OS password for guest access   | false    |
| libvirt_pool         |                  '{{ libvirt_network }}' | Libvirt storage pool name      | false    |
| libvirt_path         | '/var/lib/libvirt/{{ libvirt_network }}' | Libvirt storage pool directory | false    |
| libvirt_conn_timeout |                                     '30' | Libvirt guest conn tiemout     | false    |

The following environment variables are also supported

| Variable       |                                       Default | Description                | Required |
| :------------- | --------------------------------------------: | :------------------------- | :------- |
| LIBVIRT_PURGE  |                                         False | Purge libvirt storage pool | false    |
| LIBVIRT_LOGDIR | '/var/lib/libvirt/{{ libvirt_network }}/logs' | Libvirt log directory      | false    |

where <node_object> follows the following json schema

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "array",
  "items": [
    {
      "type": "object",
      "properties": {
        "name": {
          "type": "string"
        },
        "image": {
          "type": "url"
          "default": ""
        },
        "dhcp": {
          "type": "boolean",
          "default": False
        },
        "mem": {
          "type": "number"
          "default": 2
        },
        "cpu": {
          "type": "number",
          "default": 2
        },
        "size": {
          "type": "string",
          "default": "20G"
        }
      },
      "required": [
        "name",
        "image"
      ]
    }
  ]
}

```

## Collection playbooks

- nephelaiio.libvirt.create: Deploy network, storage pool and guests
- nephelaiio.libvirt.destroy: Destroy guests, network and storage pool

## Testing

Collection is tested against the following host OS:

- Ubuntu Noble

Collection is tested against the following guest OS:

- Ubuntu Noble
- Ubuntu Jammy
- Ubuntu Focal
- Debian Bookworm
- Alma Linux 9
- Rocky Linux 9

You can test the collection directly from sources using command `make test`

## License

This project is licensed under the terms of the [MIT License](/LICENSE)
