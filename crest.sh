#!/usr/bin/env bash

#<UDF name="PUBKEY" Label="SSH pubkey (installed for root and sudo user)?" example="ssh-rsa ..." />
#<UDF name="RESOURCE"  Label="Resource to download?" example="URL to Dockerfile or docker-compose.yml" default="" />
#<UDF name="RUNCMD" Label="Command to run?" example="docker run --name spigot --restart unless-stopped -e JVM_OPTS=-Xmx4096M -p 25565:25565 -itd mb101/docker-spigot" />
#<UDF name="SKIP" Label="Skip updates and server hardening?" example="Not recommended for production deployments" oneOf="no,yes" default="no" />

if [[ ! $PUBKEY ]]; then read -p "SSH pubkey (installed for root and sudo user)?" PUBKEY; fi
if [[ ! $RUNCMD ]]; then read -p "Command to run?" RUNCMD; fi
if [[ ! $SKIP ]]; then read -p "Skip updates and server hardening?" SKIP; fi

detect_distro() {
  # Based on https://unix.stackexchange.com/a/6348
  echo "Attempting to detect the distro and version... "
  if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    echo "Found /etc/os-release, using it."
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    echo "Found lsb_release, using it."
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then
    # some versions of Debian/Ubuntu without lsb_release command
    echo "Found /etc/lsb-release, using it."
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    echo "Found /etc/debian_version, using it."
    OS=Debian
    VER=$(cat /etc/debian_version)
  elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    echo "Found /etc/SuSe-release, using it."
    echo "SuSe-release not implemented. Stopping."
    return 1
  elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    echo "Found /etc/redhat-release, using it."
    echo "redhat-release not implemented. Stopping"
    return 1
  else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    echo "Found uname, using it."
    OS=$(uname -s)
    VER=$(uname -r)
  fi
  echo "Detected OS=$OS VER=$VER"
  sleep 2
}

fetch_distrofile() {
  # Split $OS at the first space and lowercase
  # "Debian GNU/Linux" becomes "debian"
  # This technically makes D an array, but referring to an array without an
  # index always gives you the 0th element.
  local d=$(echo $A | cut -d ' ' -f 1 | tr '[:upper:]' '[:lower:]')
  curl -o distro.sh \
    https://raw.githubusercontent.com/mb243/docker-crest/master/distros/$d.$VER.sh
  . ./distro.sh
}

main() {
  detect_distro
  fetch_distrofile
}

main
