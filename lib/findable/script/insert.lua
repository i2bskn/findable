--[[

insert.lua
* Insert and update script of evalsha.

@Author  Ken Iiboshi
@Licence MIT

@Arguments
* KEY[1]     Table name of data hash.
* KEY[2..n]  Index column name.
* ARGV[1..n] Unique id and packed data with MessagePack format.
             ex [id(unique), data(packed), id, data...]

]]

-- Functions
local function update_index(base, columns, unpacked)
  if #columns > 0 then
    for i = 1, #columns do
      local name = columns[i]
      local index_key = base .. name

      if unpacked[name] then
        redis.call("HSET", index_key, unpacked[name], unpacked["id"])
      end
    end
  end
end

-- Validations
assert(#KEYS >= 1)
assert(#ARGV % 2 == 0)

-- Redis keys
local data_tbl = KEYS[1]
local info_tbl = data_tbl .. ":info"
local index_base = data_tbl .. ":index:"

local auto_increment = "auto_increment"

-- Index count
local index_columns = {}
if #KEYS > 1 then
  for i = 2, #KEYS do
    index_columns[i - 1] = KEYS[i]
  end
end

local records = {}
for i = 1, #ARGV, 2 do
  local id = ARGV[i]
  local data = ARGV[i + 1]

  if id == "auto" then -- with auto_increment id
    id = redis.call("HINCRBY", info_tbl, auto_increment, 1)
    local unpacked = cmsgpack.unpack(data)
    unpacked["id"] = id
    update_index(index_base, index_columns, unpacked)
    data = cmsgpack.pack(unpacked)
  else
    local auto_id = redis.call("HGET", info_tbl, auto_increment)
    local need_update_info = false

    if auto_id then
      if tonumber(id) > tonumber(auto_id) then
        need_update_info = true
      end
    else
      need_update_info = true
    end

    if need_update_info then
      redis.call("HSET", info_tbl, auto_increment, id)
    end

    if #index_columns > 0 then
      local unpacked = cmsgpack.unpack(data)
      update_index(index_base, index_columns, unpacked)
    end
  end

  redis.call("HSET", data_tbl, id, data)
  records[#records + 1] = data
end

return records
