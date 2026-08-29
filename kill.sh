#!/bin/bash
# shellcheck disable=SC1091

if [[ -f .env ]]; then
  source .env
else
  printf "\n===============================================\n\n"
  printf "\e[31mError: .env not found in the current directory.\e[0m\n\n"
  printf "===============================================\n\n"
  exit 1
fi

base_name="${REDIS_NAME:-redis_server}"
redis_container="${base_name}"
redis_volume="${base_name}_data"
redis_network="${base_name}_network"

echo -e "\n========================================"
echo "Removing Redis container..."

if docker container inspect "$redis_container" >/dev/null 2>&1; then
    docker rm -f "$redis_container" >/dev/null
    echo -e "\e[32mContainer removed\e[0m"
else
    echo -e "\e[33mContainer already removed\e[0m"
fi

echo -e "========================================"
echo "Removing Redis volume..."

if docker volume inspect "$redis_volume" >/dev/null 2>&1; then
    docker volume rm "$redis_volume" >/dev/null
    echo -e "\e[32mVolume removed\e[0m"
else
    echo -e "\e[33mVolume already removed\e[0m"
fi

echo -e "========================================"
echo "Removing Redis network..."

if docker network inspect "$redis_network" >/dev/null 2>&1; then
    docker network rm "$redis_network" >/dev/null
    echo -e "\e[32mNetwork removed\e[0m"
else
    echo -e "\e[33mNetwork already removed\e[0m"
fi

echo -e "========================================\n"
