[docker-install]: docker-install.md
[redis-host-bind-ru]: redis-host-bind.ru.md
[redis-max-memory-policy-ru]: redis-max-memory-policy.ru.md

# Redis Server

[English](../README.md) | **Русский**

---

Готовая Docker-конфигурация Redis с настройкой через `.env` и простыми скриптами для развёртывания и управления одной командой.


Требуется **[Docker][docker-install]**.

Перед запуском убедитесь, что **внешний порт** не занят другими сервисами, и настройте файл `.env`

## Настройка и запуск

**Скопируйте `.env`:**
```bash
  cp .env.example .env 
```

**Настройте переменные в `.env`:**

+ `REDIS_NAME` — название, используемое для имени контейнера, хранилища и сети.
    + По умолчанию: `redis_server`
+ `REDIS_PORT` — внутренний порт Redis.
    + По умолчанию: `6379`
+ `REDIS_EXTERNAL_PORT` — внешний порт для подключения к Redis.
    + По умолчанию: `6379`
+ `REDIS_HOST_BIND_IP` — IP-адрес хоста для публикации порта, подробнее: **[Режимы работы сети][redis-host-bind-ru]**.
    + По умолчанию: `127.0.0.1`
+ `REDIS_USERNAME` — логин для подключения к Redis.
+ `REDIS_PASSWORD` — пароль для подключения к Redis.
    + Не используйте знак `>` в начале пароля
+ `REDIS_PASSWORD_TYPE` — тип пароля:
    + `>` - plain text пароль
    + `#` - пароль, хэшированный с помощью `SHA-256`
+ `REDIS_MAXMEMORY` - максимальный объём используемой оперативной памяти.
    + По умолчанию: `256mb`
+ `REDIS_MAXMEMORY_POLICY` - **[Политика вытеснения данных][redis-max-memory-policy-ru]**
    + По умолчанию: `allkeys-lru`

**Переменные поведения `run.sh`:**
+ `REDIS_HASH_PASSWORD_VERIFY_PONG` - определяет, нужно ли проверять подключение к Redis через `PING` при использовании хешированного пароля (`#`). Если `true`, `run.sh` запрашивает пароль и проверяет его через `PING`. Если `false`, проверка пропускается, а пароль будет запрошен непосредственно при открытии Redis CLI.
    + По умолчанию: `true`
+ `REDIS_OPEN_CLI` - если `true`, после успешного запуска и проверки Redis открывает Redis CLI.
    + По умолчанию: `true`

**Запустите скрипт:**

```bash
sudo ./run.sh
```

<img src="run-output.png" style="max-width: 350px;" alt="notfound">

Если приложение работает в Docker, подключите его контейнер к Docker-сети, созданной этим проектом, и используйте имя Redis-контейнера (`REDIS_NAME`) в качестве хоста. Если приложение работает непосредственно на хост-машине, используйте `REDIS_HOST_BIND_IP` и `REDIS_EXTERNAL_PORT`

## Удалить Redis-сервер

```bash
sudo ./kill.sh
```

<img src="kill-output.png" style="max-width: 350px;" alt="notfound">
