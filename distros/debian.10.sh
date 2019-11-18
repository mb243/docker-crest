#!/bin/bash
set -euo pipefail

DEBIAN_FRONTEND=noninteractive

install_pubkey() {
  # set up ssh pubkey
  echo Setting up ssh pubkey...
  mkdir -p /root/.ssh
  echo "$PUBKEY" >> /root/.ssh/authorized_keys
  echo ...done
}

disable_PasswordAuthentication() {
  # disable password over ssh
  echo Disabling password login over ssh...
  sed -i -e "s/PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
  sed -i -e "s/#PasswordAuthentication no/PasswordAuthentication no/" /etc/ssh/sshd_config
  echo Restarting sshd...
  systemctl restart sshd
  echo ...done
}

do_apt_update() {
  # Initial needfuls
  apt update -y
  apt upgrade -y
}

remove_unneeded() {
  # remove unneeded services
  echo Removing unneeded services...
  # yum remove -y avahi chrony
  echo ...done
}

configure_unattended_upgrades() {
  # Set up automatic updates
  # TODO: Make sure these work
  echo Setting up automatic updates...
  apt install -y unattended-upgrades
  cat > /etc/apt/apt.conf.d/20auto-upgrades <<__EOF__
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
__EOF__
  echo ...done
}

configure_fail2ban() {
  # set up fail2ban
  echo Setting up fail2ban...
  apt install -y fail2ban
  cd /etc/fail2ban
  cp fail2ban.conf fail2ban.local
  cp jail.conf jail.local
  systemctl enable fail2ban
  systemctl start fail2ban
  cd /
  echo ...done
}

configure_ufw() {
  apt install -y ufw
  ufw allow ssh
  ufw allow http/tcp
  ufw allow https/tcp
  ufw default allow outgoing
  ufw default deny incoming
  ufw --force enable
  ufw status
}

configure_ntp() {
  systemctl start systemd-timesyncd
}

clean_docker() {
  # Remove unneeded docker packages
  apt remove -y docker docker-engine docker.io
}

install_docker() {
  # Install Docker
  apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/debian \
     $(lsb_release -cs) \
     stable"
  apt update
  apt install -y docker-ce
  systemctl enable docker
  systemctl start docker
}

install_compose() {
  apt install -y python-pip
  pip install docker-compose
}

fetch_and_exec() {
  if [[ "$RESOURCE" != "" ]]; then
    curl -LO $RESOURCE
  fi
  # needfuls done
  echo "=== Docker install complete ==="
  echo -n "Sleeping for 2 seconds before moving on... "
  sleep 2
  echo "ship it!"
  $RUNCMD &
}

main() {
  # Always install pubkey, and do it early
  install_pubkey

  if [[ "$SKIP" != "yes" ]]; then
    configure_ufw
    disable_PasswordAuthentication
    do_apt_update
    remove_unneeded
    configure_unattended_upgrades
    configure_fail2ban
    configure_ntp
    echo "=== Server hardening complete ==="
    echo -n "Waiting for 2 seconds before starting Docker things... "
    sleep 2
    echo "here we go!"
  fi
  clean_docker
  install_docker
  install_compose
  fetch_and_exec
}

main
