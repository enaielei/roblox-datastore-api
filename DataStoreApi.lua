local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

---@class DataStoreApi
local DataStoreApi = {}
DataStoreApi.__index = DataStoreApi

--Default (Blocked by Roblox by default)
--DataStoreApi.ENDPOINT = "https://apis.roblox.com"

--Proxy (Use this instead)
--source: https://devforum.roblox.com/t/roproxycom-a-free-rotating-proxy-for-roblox-apis/1508367
DataStoreApi.ENDPOINT = "https://apis.roproxy.com"
DataStoreApi.SCOPE = "global"
DataStoreApi.STANDARD = "standard"
DataStoreApi.ORDERED = "ordered"

local debug: boolean = script:GetAttribute("Debug")
if type(debug) == "nil" then
    DataStoreApi.debug = false
else
    DataStoreApi.debug = debug
end

DataStoreApi.METHODS = {
    get="GET", post="POST", delete="DELETE", patch="PATCH"
}

function DataStoreApi.to_string_table(args: table, params: table)
    local rv = {}
    if args then
        for _, v in ipairs(args) do
            table.insert(rv, tostring(v))
        end
    elseif params then
        for k, v in pairs(params) do
            rv[tostring(k)] = tostring(v)
        end
    end
    return rv
end

function DataStoreApi.to_query(params: table)
    local query = ""
    params = DataStoreApi.to_string_table(nil, params)
    for k, v in pairs(params) do
        local fmt = #query == 0 and "%s=%s" or "&%s=%s"
        query ..= fmt:format(tostring(k), tostring(v))
    end
    return query
end

function DataStoreApi.get_body(response)
    if response.Success then
        return HttpService:JSONDecode(response.Body)
    end
end

function DataStoreApi.print(method: string, ...: any)
    if not DataStoreApi.debug or not RunService:IsStudio() then return end
    print(("[DataStoreApi:%s]"):format(method), ...)
end

function DataStoreApi.warn(method: string, ...: any)
    if not DataStoreApi.debug or not RunService:IsStudio() then return end
    warn(("[DataStoreApi:%s]"):format(method), ...)
end

---@return DataStoreApi
function DataStoreApi.new(key: string, universe: string)
    ---@type DataStoreApi
    local self = setmetatable({}, DataStoreApi)

    self.key = key
    self.universe = universe

    return self
end

function DataStoreApi:_request(url: string, method: string, headers: table?, body: any?)
    local mname = "_request"
    local hdrs = self:get_headers(headers)
    local mthd = self.METHODS[method]
    local options = {
        Url=url,
        Method=mthd,
        Headers=hdrs,
    }
    local prnt = {"url:", url}
    if body then
        body = HttpService:JSONEncode(body)
        options.Body = body
        table.insert(prnt, "body:")
        table.insert(prnt, body)
    end
    self.warn(mname, unpack(prnt))
    local response = HttpService:RequestAsync(options)
    if response.Success then
        self.warn(mname, "succeeded!")
    else
        self.warn(mname, "failed!")
        self.print(mname, response)
    end
    return response
end

function DataStoreApi:_get(endpoint: string, params: table)
    local url = self:to_url("get", endpoint, params)
    local response = self:_request(url, "get")
    return self.get_body(response)
end

function DataStoreApi:_set(endpoint: string, params: table, value)
    local url = self:to_url("create", endpoint, params)
    local response = self:_request(url, "post", {
        ["content-type"]="application/json"
    }, value)
    return self.get_body(response)
end

---@return boolean
function DataStoreApi:_delete(endpoint: string, params: table)
    local url = self:to_url("delete", endpoint, params)
    return self:_request(url, "delete").Success
end

function DataStoreApi:_update(endpoint: string, params: table, value)
    local url = self:to_url("update", endpoint, params)
    local response = self:_request(url, "patch", {
        ["content-type"]="application/json"
    }, value)
    return self.get_body(response)
end

function DataStoreApi:get_endpoints(method: string?, endpoint: string?)
    local standard = self.ENDPOINT .. "/datastores/v1/universes/" ..
        self.universe .. "/standard-datastores/datastore/entries/entry"
    local ordered = self.ENDPOINT .. "/ordered-data-stores/v1/universes/" ..
        self.universe .. "/orderedDataStores/%s/scopes/%s/entries"

    local get = {}
    get[self.STANDARD] = standard
    get[self.ORDERED] = ordered .. "/%s"

    local create = {}
    create[self.STANDARD] = get.standard
    create[self.ORDERED] = ordered .. "?id=%s"

    local update = {}
    update[self.STANDARD] = get.standard
    update[self.ORDERED] = get.ordered

    local delete = {}
    delete[self.STANDARD] = get.standard
    delete[self.ORDERED] = get.ordered

    local endpoints = {
        get=get,
        create=create,
        update=update,
        delete=delete,
    }

    if method then
        endpoints = endpoints[method]
    end
    if not endpoint then return endpoints end
    return endpoints[endpoint]
end

function DataStoreApi:get_headers(tbl: table?)
    local hdrs = {
        ["x-api-key"]=self.key
    }
    if tbl then
        for k, v in pairs(tbl) do
            hdrs[k] = v
        end
    end
    return hdrs
end

function DataStoreApi:to_url(method: string, endpoint: string, params: table)
    local epoint = self:get_endpoints(method, endpoint)
    if endpoint == self.STANDARD then
        return ("%s?%s"):format(epoint, self.to_query(params))
    elseif endpoint == self.ORDERED then
        params = self.to_string_table(params)
        return epoint:format(unpack(params))
    end
end

function DataStoreApi:get(store: string, key: string, scope: string?)
    scope = scope or self.SCOPE
    return self:_get(self.STANDARD, {
        datastoreName=store, scope=scope, entryKey=key,
    })
end

function DataStoreApi:get_ordered(store: string, key: string, scope: string?)
    scope = scope or self.SCOPE
    return self:_get(self.ORDERED, {store, scope, key})
end

function DataStoreApi:set(store: string, key: string, value, scope: string?)
    scope = scope or self.SCOPE
    return self:_set(self.STANDARD, {
        datastoreName=store, scope=scope, entryKey=key,
    }, value)
end

function DataStoreApi:set_ordered(
    store: string, key: string, value: number, scope: string?
)
    scope = scope or self.SCOPE
    return self:_set(self.ORDERED, {store, scope, key}, {value=value})
end

function DataStoreApi:delete(store: string, key: string, scope: string?)
    scope = scope or self.SCOPE
    return self:_delete(self.STANDARD, {
        datastoreName=store, scope=scope, entryKey=key,
    })
end

function DataStoreApi:delete_ordered(store: string, key: string, scope: string?)
    scope = scope or self.SCOPE
    return self:_delete(self.ORDERED, {store, scope, key})
end

function DataStoreApi:update(store: string, key: string, value, scope: string?)
    return self:set(store, key, value, scope)
end

function DataStoreApi:update_ordered(
    store: string, key: string, value: number, scope: string?
)
    scope = scope or self.SCOPE
    return self:_update(self.ORDERED, {store, scope, key}, {value=value})
end

return DataStoreApi
