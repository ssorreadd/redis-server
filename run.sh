#!/bin/bash

if [ -f .env ]; then
  source .env
else
  echo "Error: .env not found in the current directory."
  exit 1
fi

if [[ -z "$REDIS_PASSWORD" || -z "$REDIS_EXTERNAL_PORT" || -z "$REDIS_PORT" ]]; then
  echo "Error: Variables REDIS_PASSWORD, REDIS_EXTERNAL_PORT, or REDIS_PORT are not set in .env file."
  exit 1
fi

redis_container="${REDIS_NAME:-redis}"

echo -e "\n==================================="

echo "Stopping redis container..."
# Добавлено 2>/dev/null, чтобы убрать ошибку, если контейнера еще нет
docker stop "$redis_container" 2>/dev/null || true

echo -e "==================================="

docker compose up -d --build

echo -e "==================================="

echo "Checking Redis connection...  "

max_retries=3
retry_delay=1
attempt=1

while [[ $attempt -le $max_retries ]]; do
  sleep "$retry_delay"

  PING_RESULT=$(docker exec "$redis_container" redis-cli --user "$REDIS_USERNAME" -a "$REDIS_PASSWORD" --no-auth-warning ping 2>/dev/null)

  if [[ "$PING_RESULT" == "PONG" ]]; then
    printf "\e[33mPING\e[0m  ------------------>  \e[32m%s\e[0m\n" "$PING_RESULT"
    break
  else
    printf "\e[33mPING (attempt $attempt)\e[0m  ------>  \e[31m%s\e[0m\n" "$PING_RESULT"
    sleep "$retry_delay"
    ((attempt++))
  fi
done

if [[ "$PING_RESULT" != "PONG" ]]; then
  echo -e "==================================="
  printf "\e[31mRedis did not respond with PONG after $max_retries attempts.\e[0m\n"
  echo -e "==================================="

  printf "\e[31m$PING_RESULT\e[0m\n"
  echo -e "==================================="

  echo -n "Stopped: "
  docker stop "$redis_container"
  echo -e "===================================\n"
  exit 1
fi

echo -e "==================================="

echo -n "Container IP: "
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$redis_container"

echo -n "Host IP: "
ip -4 addr show docker0 | grep -o 'inet [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]' | awk '{print $2}'

echo -e "\nContainer name: ${redis_container}"
echo "Network: ${redis_container}_network"
echo "Port: ${REDIS_EXTERNAL_PORT}"

echo -e "===================================\n"

docker exec -it "$redis_container" redis-cli --user "$REDIS_USERNAME" -a "$REDIS_PASSWORD" --no-auth-warning
