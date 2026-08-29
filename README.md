[docker-install]: readme_src/docker-install.md
[redis-host-bind-en]: readme_src/redis-host-bind.en.md
[redis-max-memory-policy-en]: readme_src/redis-max-memory-policy.en.md

# Redis Server

**English** | [Русский](readme_src/README.ru.md)

---

A ready-to-use Redis Docker setup configured via `.env`, with simple scripts for one-command deployment and management.

Requires **[Docker][docker-install]**.

Before starting, make sure that the **external port** is not occupied by other services, and configure the **.env** file.

## Setup and Run

**Clone the repository:**

```bash
git clone https://github.com/ssorreadd/redis-server.git
cd redis-server
```

**Copy `.env`:**
```bash
cp .env.example .env 
```

**Configure the variables in `.env`:**

+ `REDIS_NAME` — name used for the container, volume, and network.
    + Default: `redis_server`
+ `REDIS_PORT` — internal Redis port.
    + Default: `6379`
+ `REDIS_EXTERNAL_PORT` — external port used to connect to Redis.
    + Default: `6379`
+ `REDIS_HOST_BIND_IP` — host IP address used to publish the port. See **[Network Modes][redis-host-bind-en]** for more information.
    + Default: `127.0.0.1`
+ `REDIS_USERNAME` — Redis ACL username used to connect to Redis.
+ `REDIS_PASSWORD` — Redis user password.
    + If `REDIS_PASSWORD_TYPE=#` is used, this must contain the SHA-256 hash of the password.
    + Do not use `>` at the beginning of the value, as `>` is a special Redis ACL prefix.
+ `REDIS_PASSWORD_TYPE` — Redis ACL password type:
    + `>` — plain-text password.
    + `#` — SHA-256 hashed password.
+ `REDIS_MAXMEMORY` — maximum amount of RAM that Redis can use.
    + Default: `256mb`
+ `REDIS_MAXMEMORY_POLICY` — **[Redis Max Memory Policy][redis-max-memory-policy-en]**.
    + Default: `allkeys-lru`
+ `REDIS_HEALTHCHECK_USERNAME` — Redis ACL username used for the healthcheck.
    + Default: `healthcheck`
    + The user has only the `+ping` permission.
+ `REDIS_HEALTHCHECK_PASSWORD` — password for the healthcheck user.
    + A separate password is used so that the healthcheck does not require access to the main `REDIS_USERNAME` user.
    + Do not use the main `REDIS_PASSWORD`.
    + Do not use `>` at the beginning of the password, as `>` is a special Redis ACL prefix.
    + The password must be stored in plain text. This is required because `redis-cli` must provide the original password to Redis when performing `AUTH`.
    + Separating the main and healthcheck users is intentional and allows `REDIS_PASSWORD_TYPE=#` to be used. In this mode, only the SHA-256 hash of the main password needs to be stored in the Redis configuration, without storing the password itself in plain text.

**`run.sh` behavior variables:**

+ `REDIS_HASH_PASSWORD_VERIFY_PONG` - determines whether to check the Redis connection using `PING` when a hashed password (`#`) is used. If `true`, `run.sh` prompts for the password and verifies it using `PING`. If `false`, the connection check is skipped, and the password will be requested directly when opening the Redis CLI.
    + Default: `true`
+ `REDIS_OPEN_CLI` - if `true`, opens the Redis CLI after Redis has started successfully and the connection has been verified.
    + Default: `true`

**Run the script:**

```bash
sudo ./run.sh
```

<img src="readme_src/run-output.png" style="max-width: 350px;" alt="notfound">

If the application runs in Docker, connect its container to the Docker network created by this project and use the Redis container name (`REDIS_NAME`) as the host. If the application runs directly on the host machine, use `REDIS_HOST_BIND_IP` and `REDIS_EXTERNAL_PORT`.

## Remove Redis server

```bash
sudo ./kill.sh
```

<img src="readme_src/kill-output.png" style="max-width: 350px;" alt="notfound">

## License

This project is licensed under the [MIT License](LICENSE.md).
