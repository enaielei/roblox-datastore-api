# Installation
1. Copy the `DataStoreApi.lua` module inside `ReplicatedStorage` or `ServerStorage`.
2. Import it in your scripts.
```
local DataStoreApi = require(game.ReplicatedStorage.DataStoreApi)
```

---

# Quickstart
## Creating a new DataStoreApi instance
1. Create a new [Roblox API Key](https://create.roblox.com/dashboard/credentials) and copy it.
2. Identify the game/experience's universe ID that you want to target. Can be identified using `game.GameId`.
3. Pass the `api_key` and `universe_id` to the `DataStoreApi:new` constructor.
```
local api = DataStoreApi:new("api_key", "universe_id")
```
## Creating a store entry
### Standard
```
api:set("store_name", "key", {a=1, b="b", c=3})
```
### Ordered
```
api:set_ordered("store_name", "key", 1)
```
## Getting a store entry
### Standard
```
api:get("store_name", "key")
```
### Ordered
```
api:get_ordered("store_name", "key")
```
## Updating a store entry
### Standard
```
api:update("store_name", "key", "new_value")
```
### Ordered
```
api:update_ordered("store_name", "key", 5)
```
## Deleting a store entry
### Standard
```
api:delete("store_name", "key")
```
### Ordered
```
api:delete_ordered("store_name", "key")
```

---

# Documentation
In progress...
