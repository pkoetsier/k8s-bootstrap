#!/bin/bash


PREREQ_PACKAGES="ansible curl"

function msg {
    level=0

    (($# > 1)) && { level="${1}"; shift; }
    ((verbose >= level)) || return
        echo -e "INFO $(date) ${1}"
}

function warn {
    echo -e "WARNING $(date) ${1}" >&2
    ((errors++))
}

function err {
    echo -e "ERROR $(date) ${1}" >&2
    ((errors++))
}

function die {
    rc=1

    (($# > 1)) && { rc="${1}"; shift; }
    err "${1}"

    exit ${rc}
}

function install_prereqs {
  for package in ${PREREQ_PACKAGES}; do
    dpkg -l ${package} >/dev/null 2>&1 || sudo apt install -y ${package} || die "failed to install ${package}"
  done
}

function install_ansible_galaxy_roles {
  [ -e galaxy_roles.yaml ] || die "cannot find galaxy_roles.yaml"
  ansible-galaxy role install -r galaxy_roles.yaml || die "failed to install Ansible Galaxy roles"

}

function passwd_hash {
  echo -n ansible | openssl passwd -6 -stdin
}

function create_ssh_key {
  [ -e .ssh/ansible ] && return 0

  [ -d .ssh ] || mkdir .ssh || die "failed to create .ssh directory"
  ssh-keygen -b 2048 -N "" -f .ssh/ansible || die "failed to create ansible SSH keypair"
}

function install_k8s_cluster {
   ansible-playbook -v -i inventory.yaml install_vms.yaml || die "failed to install VMs"
   sleep 60
   ansible-playbook -v -i inventory.yaml install_kubernetes.yaml || die "failed to install K8S cluster"
   ansible-playbook -v -i inventory.yaml install_storage_provisioners.yaml || die "failed to install storage provisioners"
   ansible-playbook -v -i inventory.yaml install_logmon.yaml || die "failed to install logging & monitoring"
}

function install_helm {
  [ -e bin/helm ] && return 0

  [ -d bin ] || mkdir bin || die "failed to create the bin directory"
  curl -fsSL -o bin/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 || die "failed to download get_helm.sh"
  chmod a+rx bin/get_helm.sh
  PATH="${PATH}:bin" HELM_INSTALL_DIR=bin bin/get_helm.sh || die "failed to install helm"

  return 0
}


# Main
install_prereqs
install_ansible_galaxy_roles || die "failed to install the needed Ansible galaxy roles"
create_ssh_key
#passwd_hash
install_helm
install_k8s_cluster
