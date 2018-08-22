#!/usr/bin/env bash

# based on https://github.com/hwdsl2/docker-ipsec-vpn-server

# TODO: Configure this to load on every boot
sudo modprobe af_key

# write out the docker-compose file
cat > docker-compose.yml <<__EOF__
version: '2'

services:
  vpn:
    image: hwdsl2/ipsec-vpn-server
    restart: always
    environment:
      - VPN_IPSEC_PSK=$VPNPSK
      - VPN_USER=$VPNUSERNAME
      - VPN_PASSWORD=$VPNPASSWORD
    ports:
      - "500:500/udp"
      - "4500:4500/udp"
    privileged: true
    hostname: ipsec-vpn-server
    container_name: ipsec-vpn-server
    volumes:
      - /lib/modules:/lib/modules:ro
__EOF__

docker-compose up
