[docker-install]: readme_src/docker-install.md
[redis-host-bind-en]: readme_src/redis-host-bind.en.md
[redis-max-memory-policy-en]: readme_src/redis-max-memory-policy.en.md

# Redis Server

**English** | [Русский](readme_src/README.ru.md)

---

An application for quickly deploying a basic Redis server for local development.

[//]: # (An advanced version with separate containers for cache and queues can be found **[HERE]&#40;&#41;**.)

Uses **[Docker][docker-install]**.

Before starting, make sure that the **external port** is not occupied by other services, and configure the **.env** file.

## Setup and Run

**Copy .env:**
```bash
  cp .env.example .env 
```

**Configure the variables in .env:**

+ **REDIS_NAME** — the name used for the container, storage, and network.
    + Default: `redis_server`
+ **REDIS_PORT** — the internal Redis port.
    + Default: `6379`
+ **REDIS_EXTERNAL_PORT** — the external port for connecting to Redis.
    + Default: `6379`
+ **REDIS_HOST_BIND** — the host IP address for publishing the port, see **[Network Modes][redis-host-bind-en]** for more details.
    + Default: `127.0.0.1`
+ **REDIS_USERNAME** — username for connecting to Redis.
+ **REDIS_PASSWORD** — password for connecting to Redis.
    + Do not use the ">" character at the beginning of the password
+ **REDIS_PASSWORD_TYPE** — password type:
    + **>** - plain text password
    + **#** - hashed password
+ **REDIS_MAXMEMORY** - maximum amount of RAM to be used.
    + Default: `256mb`
+ **REDIS_MAXMEMORY_POLICY** - **[Max Memory Policy][redis-max-memory-policy-en]**
    + Default: `allkeys-lru`

**Run the script:**

```bash
  sudo ./run.sh
```

If the projects that will use this Redis server are located on the same machine, you should use the **Host IP** to connect or the specified network.

<img src="readme_src/run-output.png" style="max-width: 350px;" alt="notfound">

## Remove Redis server

```bash
  sudo ./kill.sh
```