#!/bin/bash

cat >> docker-compose.yml <<__EOF__
version: '3.1'

services:

  db:
    image: mysql
    command: --default-authentication-plugin=mysql_native_password
    restart: always
    environment:
      MYSQL_RANDOM_ROOT_PASSWORD: "yes"
    ports:
      - 3306:3306
__EOF__

ufw allow mysql

docker-compose up
