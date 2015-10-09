--[[

insert.lua
* Findable data insert and update script of evalsha.

@Author  Ken Iiboshi
@Licence MIT
@URL     https://github.com/i2bskn/findable

@Arguments
* KEYS[1]    Data hash name.
* KEYS[2]    Info hash name.
* KEYS[3..n] Index hash names.
* ARGV[1..n] Packed data with MessagePack format.

@Return [Packed hash, Packed hash...]

]]

assert(#KEYS >= 2)
assert(#ARGV > 0)

local primary_key = "id"
local auto_increment = "auto_increment"

local last_id = 0
local need_update_auto_increment = false
local packed_stack = {}

local index_map = {}
if #KEYS > 2 then
  for i = 3, #KEYS do
    local reversed = string.reverse(KEYS[i])
    local pos = string.find(reversed, ":")
    local name = string.reverse(string.sub(reversed, 1, pos - 1))
    index_map[name] = {key = KEYS[i], new_ids = {}}
  end
end

local result = {}
for i = 1, #ARGV do
  local unpacked = cmsgpack.unpack(ARGV[i])
  local id = tonumber(unpacked[primary_key]) or 0

  if id == 0 then
    id = tonumber(redis.call("hincrby", KEYS[2], auto_increment, 1))
    unpacked[primary_key] = id
    last_id = id
  else
    if last_id == 0 then
      last_id = tonumber(redis.call("hget", KEYS[2], auto_increment))
    end

    if last_id == nil or id > last_id then
      need_update_auto_increment = true
    end
  end

  for column, meta in pairs(index_map) do
    if unpacked[column] then
      local old_ids = redis.call("hget", meta.key, unpacked[column])

      if old_ids then
        local unpacked_ids = cmsgpack.unpack(old_ids)
        local need_update_index = true

        for i = 1, #unpacked_ids do
          if unpacked_ids[i] == id then
            need_update_index = false
            break
          end
        end

        if need_update_index then
          table.insert(unpacked_ids, id)
          table.insert(meta.new_ids, unpacked[column])
          table.insert(meta.new_ids, cmsgpack.pack(unpacked_ids))
        end
      else
        table.insert(meta.new_ids, unpacked[column])
        table.insert(meta.new_ids, cmsgpack.pack({id}))
      end
    end
  end

  local repacked = cmsgpack.pack(unpacked)
  table.insert(result, repacked)
  table.insert(packed_stack, id)
  table.insert(packed_stack, repacked)
end

-- commit records
redis.call("hmset", KEYS[1], unpack(packed_stack))

-- commit index
for column, meta in pairs(index_map) do
  redis.call("hmset", meta.key, unpack(meta.new_ids))
end

return result
