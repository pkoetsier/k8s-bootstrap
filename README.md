# k8s-bootstrap
## Bootstrap a lab K8S cluster on KVM VMs
### General description
This repository contains tools which can be used to setup a Kubernetes lab cluster on KVM VMs quickly.
It has these prequisites:

- A Debian Linux host with KVM + libvirtd configured.
- An NFS export acessible to all VMs with root squash disabled for use by the nfs-subdir-external-provisioner.
- 500 GB of disk space for the Debian base image used to create the VMs.
- 4 GB of disk space per VM.
- 4 GiB of RAM per VM.

### Usage
- `inventory.yaml` contains the list of VMs which will be provisioned, their IP addresses, the K8S version and the NFS server details. Adapt it to your needs.
- `bootstrap.sh` is used to provisioned the VMs and bootstrap the K8S cluster. It takes care of installing the prequisite Debian software packages and Ansible Galaxy roles.
- `configure_control_plane/files/etc/kubernetes/kubeadm-config.yaml` contains a list of SANs (Subject Alternative Names) which `kubeadm` will use for the control-plane server certificate. You can adapt it to your needs.

Following the bootstrap, the .ssh directory will contain a SSH keypair which can be used to login to the VMs like so:

```
ssh -i .ssh/ansible -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ansible@<node>
```

The ansible user has full `NOPASSWD` Sudo access.

Following the bootstrap, the kubernetes directory will contain the `admin.conf` file copied from the primary control-plane node. It can be used to access the Kubernetes cluster like so:

```
KUBECONFIG=kubernetes/admin.conf kubectl cluster-info
```
