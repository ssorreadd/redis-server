# Redis Max Memory Policy

**English** | [Русский](redis-max-memory-policy.ru.md)

Redis has **8 main eviction policies**. They determine how Redis will remove old keys when the amount of data reaches the limit specified by the `REDIS_MAXMEMORY` variable.

They can be divided into 3 main groups depending on the algorithm:

1. **LRU (Least Recently Used)** — removes keys that have not been used for the **longest time**.
2. **LFU (Least Frequently Used)** — removes keys that are used **least frequently** (based on the access counter).
3. **Random / TTL** — removes keys randomly or based on their expiration time.

---

Summary table of policies (`REDIS_MAXMEMORY_POLICY`)

|Variable value|Algorithm|Keys it applies to|Behavior|
|---|---|---|---|
|**`allkeys-lru`** _(Recommended)_|LRU|**All keys** without exception|Removes the oldest keys. A universal choice for a typical cache.|
|**`volatile-lru`**|LRU|Only keys with **TTL** (expire)|Removes the oldest keys, but only those with an expiration time set.|
|**`allkeys-lfu`**|LFU|**All keys** without exception|Removes keys with the lowest request frequency.|
|**`volatile-lfu`**|LFU|Only keys with **TTL** (expire)|Removes the least frequently used keys among those with a TTL.|
|**`volatile-ttl`**|TTL|Only keys with **TTL** (expire)|Removes keys with the **least remaining time to live** (those closest to expiration).|
|**`allkeys-random`**|Random|**All keys** without exception|Simply removes random keys to free up space.|
|**`volatile-random`**|Random|Only keys with **TTL** (expire)|Removes random keys, but only from those with a TTL.|
|**`noeviction`** _(Default)_|—|None|**Does not remove anything**. When memory is full, Redis will block write operations and return the `OOM command not allowed` error.|
