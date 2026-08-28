# Network Modes

**English** | [Русский](redis-host-bind.ru.md)

Depending on your requirements, you can switch Redis's accessibility mode using a single `REDIS_HOST_BIND_IP` variable in the `.env` file:

1. **Local mode**
    * **Configuration:** `REDIS_HOST_BIND_IP=127.0.0.1`
    * **How it works:** The port is completely inaccessible from the internet. Applications running in neighboring Docker containers on the `redis_network` network can connect without any issues. You can connect to the database from the host machine or through an SSH tunnel.

2. **Public mode**
    * **Configuration:** `REDIS_HOST_BIND_IP=0.0.0.0`
    * **How it works:** The Redis port is exposed to the public internet. You will be able to connect to it directly from anywhere in the world (for example, using Redis Insight on your work computer).
    * *Warning:* Make sure to set a long and strong `REDIS_PASSWORD` before enabling this mode.
