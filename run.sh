#!/bin/bash
# shellcheck disable=SC1091

check_redis_ping() {
  local password="$1"
  local attempt=1
  local max_attempts=3
  local result=""

  echo "==================================================="

  while [[ $attempt -le $max_attempts ]]; do
    sleep 1

    result=$(
      docker exec \
        -e REDISCLI_AUTH="$password" \
        "$redis_container" \
        redis-cli --user "$REDIS_USERNAME" ping 2>&1
    )

    result=$(printf '%s' "$result" | tr -d '\r' | sed '/^[[:space:]]*$/d')

    if [[ "$result" == "PONG" ]]; then
      printf "\e[33mPING\e[0m ----------------------------------> \e[32mPONG\e[0m (%d/%d)\n" \
        "$attempt" "$max_attempts"
      return 0
    fi

    if [[ "$result" == *"WRONGPASS"* || "$result" == *"NOAUTH"* ]]; then
      printf "\e[31mAuthentication failed\e[0m\n"
      printf "Reason: \e[31m%s\e[0m\n" "$result"
      return 2
    fi

    printf "\e[31mPING failed\e[0m (%d/%d)\n" \
      "$attempt" "$max_attempts"

    if [[ -n "$result" ]]; then
      printf "Reason: \e[31m%s\e[0m\n" "$result"
    else
      printf "Reason: \e[31mNo response from Redis\e[0m\n"
    fi

    ((attempt++))
  done

  printf "\n\e[31mRedis connection failed after %d attempts.\e[0m\n" \
    "$max_attempts"

  return 1
}

redis_started=false

handle_interrupt() {
  printf "\n===================================================\n\n"

  if [[ "$redis_started" == true ]]; then
    printf "\e[33mRedis is still running in the background.\e[0m\n"
    printf "\e[33mUse 'docker compose down' or run 'kill.sh'\nto stop it.\e[0m\n"
  else
    printf "\e[33mRedis was not started successfully.\e[0m\n"
  fi

  printf "\n===================================================\n\n"

  exit 130
}

trap handle_interrupt INT

# ===================================================
# Load environment
# ===================================================

if [[ -f .env ]]; then
  source .env
else
  printf "\n===============================================\n\n"
  printf "\e[31mError: .env not found in the current directory.\e[0m\n\n"
  printf "===============================================\n\n"
  exit 1
fi

# ===================================================
# Validate configuration
# ===================================================

if [[ -z "${REDIS_USERNAME:-}" || -z "${REDIS_PASSWORD:-}" || -z "${REDIS_HEALTHCHECK_PASSWORD:-}" ]]; then
  printf "\n=====================================================================================\n\n"
  printf "\e[31mError: Required Redis variables are not set in .env file.\e[0m\n"
  printf "Please check REDIS_USERNAME, REDIS_PASSWORD and REDIS_HEALTHCHECK_PASSWORD variables.\n\n"
  printf "=====================================================================================\n\n"
  exit 1
fi


redis_container="${REDIS_NAME:-redis_server}"
password_type="${REDIS_PASSWORD_TYPE:->}"
hash_password_verify_pong="${REDIS_HASH_PASSWORD_VERIFY_PONG:-true}"

VALID_PLAIN_PASSWORD=""

# ===================================================
# Start Redis
# ===================================================

printf "\n===================================================\n"

echo "Stopping Redis container..."
if docker container inspect "$redis_container" >/dev/null 2>&1; then
    docker rm -f "$redis_container" >/dev/null
    echo -e "\e[32mContainer stopped\e[0m"
else
    echo -e "\e[33mContainer does not exist\e[0m"
fi
docker stop "$redis_container" 2>/dev/null || true

echo "==================================================="

echo "Starting Redis..."

if ! docker compose up -d; then
  printf "\e[31mError: Failed to start Redis.\e[0m\n"
  exit 1
fi

redis_started=true

echo "==================================================="

# ===================================================
# Password verification
# ===================================================

if [[ "$password_type" != "#" ]]; then
  VALID_PLAIN_PASSWORD="$REDIS_PASSWORD"

  echo "Checking Redis connection..."

  if ! check_redis_ping "$VALID_PLAIN_PASSWORD"; then
    echo "==================================================="

    printf "\e[31mError: Redis connection failed.\e[0m\n\n"

    echo "Stopping Redis container..."
    docker stop "$redis_container" 2>/dev/null || true

    echo "==================================================="
    exit 1
  fi
else
  if [[ "$hash_password_verify_pong" == "false" ]]; then
    printf "\e[33mSkipping verification loop\e[0m\n"
  else
    printf "\e[33mNotice:\e[0m Redis is secured with a hashed password (#)\n"

    while true; do
      printf "Please enter the PLAIN TEXT password to connect: "
      read -rs ENTERED_PASSWORD
      printf "\n"

      check_redis_ping "$ENTERED_PASSWORD"
      ping_status=$?

      if [[ $ping_status -eq 0 ]]; then

        VALID_PLAIN_PASSWORD="$ENTERED_PASSWORD"
        break

      elif [[ $ping_status -eq 2 ]]; then

        printf "\e[31mWrong password. Please try again.\e[0m\n"

      else

        printf "\e[31mRedis is unavailable. Please try again.\e[0m\n"

      fi

      echo "==================================================="
    done
  fi
fi

# ===================================================
# Redis information
# ===================================================

echo "==================================================="

echo -n "Container IP: "
docker inspect \
  -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
  "$redis_container"

docker_host_ip=$(ip -4 addr show docker0 2>/dev/null |
  awk '/inet / {print $2}' |
  cut -d/ -f1)

printf 'Docker Host IP: %s\n\n' "${docker_host_ip:-N/A}"

printf 'Container name: %s\n' "$redis_container"
printf 'Network: %s\n\n' "${redis_container}_network"

printf 'Host bind IP: %s\n' "${REDIS_HOST_BIND_IP:-127.0.0.1}"
printf 'External port: %s\n' "${REDIS_EXTERNAL_PORT}"

echo "==================================================="

# ===================================================
# Redis CLI
# ===================================================

if [[ "${REDIS_OPEN_CLI:-true}" == "true" ]]; then
  if [[ "$password_type" == "#" && "$hash_password_verify_pong" == "false" ]]; then

    printf "\nOpening Redis CLI... (Interactive fallback mode)\n"

    docker exec -it \
      "$redis_container" \
      redis-cli \
      --user "$REDIS_USERNAME" \
      --askpass
  else
    printf "\nOpening Redis CLI...\n"
    printf "Type 'exit' to leave.\n\n"

    docker exec -it \
      -e REDISCLI_AUTH="$VALID_PLAIN_PASSWORD" \
      "$redis_container" \
      redis-cli \
      --user "$REDIS_USERNAME"
  fi

  echo ""
  echo "==================================================="

  printf "\n\e[33mRedis is still running after exiting the CLI.\e[0m\n"
  printf "\e[33mUse 'docker compose down' or run 'kill.sh'\nto stop it.\e[0m\n"
else
  printf "\n\e[32mRedis is running successfully in the background.\e[0m\n"
fi

echo ""
echo "==================================================="
echo ""
