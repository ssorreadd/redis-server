#!/bin/bash

source .env

if [[ -z "$REDIS_PASSWORD" || -z "$REDIS_EXTERNAL_PORT" ]]; then
  echo "Error: Variables REDIS_PASSWORD or REDIS_EXTERNAL_PORT or REDIS_PORT are not set in .env file."
  exit 1
fi

redis_container="redis"

containers=(
  "redis"
  "redis-nginx"
)

echo "Stopping specified containers..."
for container in "${containers[@]}"; do
  docker stop "$container"
done

echo "Rebuilding and starting containers..."
docker compose up -d --build

echo "Checking Redis connection..."
echo "PING?"
docker compose exec "$redis_container" redis-cli -a "$REDIS_PASSWORD" --no-auth-warning ping

#echo "Allowing external Redis port $REDIS_EXTERNAL_PORT in ufw..."
#ufw allow "$REDIS_EXTERNAL_PORT"/tcp

## Проверяем, что порт открыт
#echo "Checking if the port $REDIS_EXTERNAL_PORT is open..."
#ss -tlnp | grep "$REDIS_EXTERNAL_PORT"

echo "Container IP:"
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' redis-redis-1

docker compose exec "$redis_container" redis-cli -a "$REDIS_PASSWORD" --no-auth-warning