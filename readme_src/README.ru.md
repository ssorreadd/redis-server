[docker-install]: docker-install.md
[redis-host-bind-ru]: redis-host-bind.ru.md
[redis-max-memory-policy-ru]: redis-max-memory-policy.ru.md

# Redis Server

[English](../README.md) | **Русский**

---

Приложение для быстрой развертки базового Redis-сервера для локальной разработки.

[//]: # (Расширенную версию с отдельными контейнерами для кеша и очередей можно посмотреть **[ЗДЕСЬ]&#40;&#41;**.)

Используется **[Docker][docker-install]**.

Перед запуском убедитесь, что **внешний порт** не занят другими сервисами, и настройте файл **.env**

## Настройка и запуск

**Скопируйте .env:**
```bash
  cp .env.example .env 
```

**Настройте переменные в .env:**

+ **REDIS_NAME** — название, используемое для имени контейнера, хранилища и сети.
    + По умолчанию: `redis_server`
+ **REDIS_PORT** — внутренний порт Redis.
    + По умолчанию: `6379`
+ **REDIS_EXTERNAL_PORT** — внешний порт для подключения к Redis.
    + По умолчанию: `6379`
+ **REDIS_HOST_BIND** — IP-адрес хоста для публикации порта, подробнее: **[Режимы работы сети][redis-host-bind-ru]**.
    + По умолчанию: `127.0.0.1`
+ **REDIS_USERNAME** — логин для подключения к Redis.
+ **REDIS_PASSWORD** — пароль для подключения к Redis.
    + Не используйте знак ">" вначале пароля
+ **REDIS_PASSWORD_TYPE** — тип пароля:
    + **>** - plain text пароль
    + **#** - хэш-пароль
+ **REDIS_MAXMEMORY** - максимум занимаемой оперативной памяти.
    + По умолчанию: `256mb`
+ **REDIS_MAXMEMORY_POLICY** - **[Политика вытеснения данных][redis-max-memory-policy-ru]**
    + По умолчанию: `allkeys-lru`

**Запустите скрипт:**

```bash
  sudo ./run.sh
```

Если проекты, которые будут использовать данный Redis-сервер расположены на одной машине, следует использовать **Host IP** для подключения или указанную сеть

<img src="run-output.png" style="max-width: 350px;" alt="notfound">

## Удалить Redis-сервер

```bash
  sudo ./kill.sh
```