#!/bin/bash

source .env

if [[ -z "$REDIS_PASSWORD" || -z "$REDIS_EXTERNAL_PORT" || -z "$REDIS_PORT" ]]; then
  echo "Error: Variables REDIS_PASSWORD, REDIS_EXTERNAL_PORT, or REDIS_PORT are not set in .env file."
  exit 1
fi

redis_container="redis_server"

containers=(
  "redis_server"
)

echo -e "\n==================================="

echo "Stopping specified containers..."
for container in "${containers[@]}"; do
  docker stop "$container"
done

echo -e "==================================="

docker compose up -d

echo -e "==================================="

echo "Checking Redis connection...  "

PING_RESULT=$(docker compose exec "$redis_container" redis-cli -a "$REDIS_PASSWORD" --no-auth-warning ping 2>/dev/null)

if [[ "$PING_RESULT" == "PONG" ]]; then
  printf "\e[33mPING\e[0m  ------------------>  \e[32m%s\e[0m\n" "$PING_RESULT"
else
  printf "\e[33mPING\e[0m  ------------------>  \e[31mFailed\e[0m\n"

  echo -e "==================================="
  printf "\e[31m$PING_RESULT\e[0m\n"
  echo -e "==================================="

  echo -n "Stopped: "
  docker stop "$redis_container"
  echo -e "===================================\n"
  exit 1
fi

#echo "Allowing external Redis port $REDIS_EXTERNAL_PORT in ufw..."
#ufw allow "$REDIS_EXTERNAL_PORT"/tcp

## Проверяем, что порт открыт
#echo "Checking if the port $REDIS_EXTERNAL_PORT is open..."
#ss -tlnp | grep "$REDIS_EXTERNAL_PORT"

echo -e "==================================="

echo -n "Container IP: "
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$redis_container"

echo -n "Host IP: "
ip -4 addr show docker0 | grep -o 'inet [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | awk '{print $2}'

echo "Port: $REDIS_EXTERNAL_PORT"

echo -e "===================================\n"

docker compose exec -it "$redis_container" redis-cli -a "$REDIS_PASSWORD" --no-auth-warning
