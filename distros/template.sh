#!/bin/bash
set -euo pipefail

install_ssh_pubkey() {
  echo Setting up ssh pubkey...
  # Commands to install an SSH pubkey for root
  # These steps are probably the same for all systems
  mkdir -p /root/.ssh
  echo "$PUBKEY" >> /root/.ssh/authorized_keys
  chmod -R 700 /root/.ssh
  echo ...done
}

disable_ssh_PasswordAuthentication() {
  echo Disabling password login over ssh...
  # Commands to disable password authentication over SSH
  echo ...done
}

do_pkg_update() {
  # Commands to update installed packages using the distro package manager
}

remove_unneeded_services() {
  echo Removing unneeded services...
  # remove unneeded services
  echo ...done
}

configure_unattended_upgrades() {
  echo Setting up automatic updates...
  # Commands to enable automatic unattended package upgrades for the distro
  echo ...done
}

configure_fail2ban() {
  echo Setting up fail2ban...
  # set up fail2ban
  echo ...done
}

configure_firewall() {
  # Configure the firewall
}

configure_ntp() {
  # ensure ntp is installed and running
}

install_docker() {
  # Install Docker
  # https://docs.docker.com/install/
  echo "=== Installing Docker ==="
}

install_compose() {
  # Install docker-compose via pip
  # Will need pip installed first
  pip install -U pip
  pip install docker-compose
}

fetch_and_exec() {
  if [[ "$RESOURCE" != "" ]]; then
    curl -LO $RESOURCE
  fi
  # needfuls done
  $RUNCMD &
}

main() {
  # Always install pubkey, and do it early
  install_ssh_pubkey

  if [[ "$SKIP" != "yes" ]]; then
    echo "=== Starting server hardening ==="
    sleep 2
    configure_firewall
    disable_ssh_PasswordAuthentication
    do_pkg_update
    remove_unneeded_services
    configure_unattended_upgrades
    configure_fail2ban
    configure_ntp
    echo "=== Server hardening complete ==="
    sleep 2
  fi
  install_docker
  install_compose
  fetch_and_exec
}

main
