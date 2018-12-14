#!/bin/bash

install_pubkey() {
  # set up ssh pubkey
  echo Setting up ssh pubkey...
  mkdir -p /root/.ssh
  echo "$PUBKEY" >> /root/.ssh/authorized_keys
  chmod -R 700 /root/.ssh
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

do_dnf_update() {
  # Initial needfuls
  dnf update -y
}

remove_unneeded() {
  # remove unneeded services
  echo Removing unneeded services...
  dnf remove -y avahi chrony
  echo ...done
}

configure_yum_cron() {
  # Set up automatic updates
  echo Setting up automatic updates...
  dnf install -y yum-cron
  sed -i -e "s/apply_updates = no/apply_updates = yes/" /etc/yum/yum-cron.conf
  echo ...done
}

configure_fail2ban() {
  # set up fail2ban
  echo Setting up fail2ban...
  dnf install -y fail2ban
  cd /etc/fail2ban
  cp fail2ban.conf fail2ban.local
  cp jail.conf jail.local
  sed -i -e "s/backend = auto/backend = systemd/" /etc/fail2ban/jail.local
  systemctl enable fail2ban
  systemctl start fail2ban
  cd /
  echo ...done
}

configure_ntp() {
  # ensure ntp is installed and running
  dnf install -y ntp
  systemctl enable ntpd
  systemctl start ntpd
}

clean_docker() {
  # Remove unneeded docker packages
  sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine
}

install_docker() {
  # Install Docker
  sudo dnf -y install dnf-plugins-core
  sudo dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo
  sudo dnf install docker-ce
  systemctl enable docker
  systemctl start docker
}

install_compose() {
  pip install -U pip
  pip install docker-compose
}

fetch_and_exec() {
  if [[ "$RESOURCE" != "" ]]; then
    dnf install -y wget
    wget $RESOURCE
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
  if [[ "$SKIP" = "no" ]]; then
    disable_PasswordAuthentication
    do_dnf_update
    remove_unneeded
    configure_yum_cron
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
