#!/bin/bash

source .env

redis_container="${REDIS_NAME}"
redis_volume="${REDIS_NAME}_data"
redis_network="${REDIS_NAME}_network"

echo -e "\n==================================="

echo "Stopping redis container container..."
docker stop "$redis_container"

echo -e "==================================="

echo "Remove redis container..."
docker rm $redis_container

echo -e "==================================="

echo "Remove redis volume..."
docker volume rm $redis_volume

echo -e "==================================="

echo "Remove redis network..."
docker network rm $redis_network

echo -e "==================================="

echo "Remove .conf & .acl files..."
rm -rf redis.conf users.acl

echo -e "===================================\n"