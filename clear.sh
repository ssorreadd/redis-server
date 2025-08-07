#!/bin/bash

redis_container="redis_server"
redis_volume="redis_redis_data"

containers=(
  "redis_server"
)

echo -e "\n==================================="

echo "Stopping specified containers..."
for container in "${containers[@]}"; do
  docker stop "$container"
done

echo -e "==================================="

echo "Remove redis container..."
docker rm $redis_container

echo -e "==================================="

echo "Remove redis volume..."
docker volume rm $redis_volume

echo -e "==================================="

echo "Remove .conf & .acl files..."
rm -rf redis.conf users.acl

echo -e "===================================\n"