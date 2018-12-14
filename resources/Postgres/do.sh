#!/usr/bin/env bash

# write out the docker-compose file
cat > docker-compose.yml <<__EOF__
# Use postgres/password user/password credentials
version: '3.1'

services:

  db:
    image: postgres
    restart: always
    environment:
      POSTGRES_PASSWORD: $POSTGRESPASSWORD
    ports:
      - 5432:5432
__EOF__

docker-compose up
