# k8s-bootstrap
## Bootstrap a lab K8S cluster on KVM VMs
### General description
This repository contains tools which can be used to setup a Kubernetes lab cluster in KVM VMs quickly.
It has these prequisites:

- A Debian Linux host with KVM + libvirtd configured
- 4 GB of disk space per VM
- 4 GiB of RAM per VM

### Usage
- `inventory.yaml` contains the list of VMs which will be provisioned, their IP addresses and the K8S version. Adapt it to your needs.
- `bootstrap.sh` is used to provisioned the VMs and bootstrap the K8S cluster.
It takes care of installing the prequisite Debian software packages and Ansible Galaxy roles.

Following the bootstrap, the .ssh directory will contain a SSH keypair which can be used to login to the VMs like so:

```
ssh -i .ssh/ansible -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ansible@<node>
```

The ansible user has full `NOPASSWD` Sudo access.
