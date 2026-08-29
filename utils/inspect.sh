#!/bin/bash

if [[ -f ../.env ]]; then
  source ../.env
else
  printf "\n===============================================\n\n"
  printf "\e[31mError: .env not found in the current directory.\e[0m\n\n"
  printf "===============================================\n\n"
  exit 1
fi

redis_container="${REDIS_NAME:-redis_server}"

printf "\n================================== docker compose config ==================================\n"
docker compose config

printf "\n\n================================== docker inspect redis ===================================\n"
docker inspect ${redis_container} --format '{{json .State}}' | jq
