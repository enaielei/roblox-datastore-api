

# Overview
This module facilitates `DataStore` and `OrderedDataStore` communication between different Roblox experiences or games. Currently, it allows basic [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) operations by passing parameters to the Standard Data Store and Ordered Data Store API endpoints and sending them over as requests.

---

# Installation
1. Copy the `DataStoreApi.lua` module file inside `ReplicatedStorage` or `ServerStorage`.
2. Import it in your scripts.
```lua
local DataStoreApi = require(game.ReplicatedStorage.DataStoreApi)
```

---

# Quickstart
## Creating a `DataStoreApi` instance
1. Create a new [Roblox API Key](https://create.roblox.com/dashboard/credentials) and copy it. The key should have read and write access permissions to both `Ordered DataStore` and `DataStore`. For the Accepted IP Addresses you can just include `0.0.0.0/0` as stated in [here](https://create.roblox.com/docs/reference/cloud/managing-api-keys#creating-api-keys).
2. Identify the game/experience's universe ID that you want to target. It can be identified using `game.GameId`.
3. Pass the `api_key` and `universe_id` to the `DataStoreApi:new` constructor.
```lua
local api = DataStoreApi:new("api_key", "universe_id")
```
## Creating a store entry
### Standard
```lua
local response = api:set("store_name", "key", {a=1, b="b", c=3})
print(response and "succeeded!" or "failed!")
```
### Ordered
```lua
local response = api:set_ordered("store_name", "key", 1)
print(response and "succeeded!" or "failed!")
```
## Getting a store entry
### Standard
```lua
local response = api:get("store_name", "key")
print(response)
```
### Ordered
```lua
local response = api:get_ordered("store_name", "key")
print(response and response.value or nil)
```
## Updating a store entry
### Standard
```lua
local response = api:update("store_name", "key", "new_value")
print(response and "succeeded!" or "failed!")
```
### Ordered
```lua
local response = api:update_ordered("store_name", "key", 5)
print(response and "succeeded!" or "failed!")
```
## Deleting a store entry
### Standard
```lua
local response = api:delete("store_name", "key")
print(response and "succeeded!" or "failed!")
```
### Ordered
```lua
local response = api:delete_ordered("store_name", "key")
print(response and "succeeded!" or "failed!")
```

---

# Documentation
In progress...

---

# References
* [Standard DataStore API](https://create.roblox.com/docs/reference/cloud/datastores-api/v1)
* [Ordered DataStore API](https://create.roblox.com/docs/reference/cloud/datastores-api/ordered-v1)
* [Managing Roblox API Keys](https://create.roblox.com/docs/reference/cloud/managing-api-keys)
* [RoProxy](https://devforum.roblox.com/t/roproxycom-a-free-rotating-proxy-for-roblox-apis/1508367)
