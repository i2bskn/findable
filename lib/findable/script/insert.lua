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

local last_id = tonumber(redis.call("hget", KEYS[2], auto_increment)) or 0
local need_update_auto_increment = false

-- for index calculation
local index_map = {}
local unpacked_stack = {}
local insert_ids = {}
local need_index_calculation = false

if #KEYS > 2 then
  need_index_calculation = true

  for i = 3, #KEYS do
    local reversed = string.reverse(KEYS[i])
    local pos = string.find(reversed, ":")
    local name = string.reverse(string.sub(reversed, 1, pos - 1))
    index_map[name] = {key = KEYS[i], add_index_stack = {}}
  end
end

local result = {} -- for return objects.
local packed_stack = {} -- for data commit.

for i = 1, #ARGV do
  local unpacked = cmsgpack.unpack(ARGV[i])
  local id = tonumber(unpacked[primary_key]) or 0

  if id == 0 then
    id = last_id + 1
    unpacked[primary_key] = id
    last_id = id
    need_update_auto_increment = true
  else
    if id > last_id then
      last_id = id
      need_update_auto_increment = true
    end
  end

  if need_index_calculation then
    unpacked_stack[id] = unpacked
    table.insert(insert_ids, id)
  end

  local repacked = cmsgpack.pack(unpacked)
  table.insert(result, repacked)
  table.insert(packed_stack, id)
  table.insert(packed_stack, repacked)
end

if need_index_calculation then
  local already_exists = redis.call("hmget", KEYS[1], unpack(insert_ids))
  local old_unpacked_stack = {}

  for i = 1, #already_exists do
    if already_exists[i] then
      local old_unpacked = cmsgpack.unpack(already_exists[i])
      old_unpacked_stack[tonumber(old_unpacked[primary_key])] = old_unpacked
    end
  end

  for id, unpacked in pairs(unpacked_stack) do
    local old_unpacked = old_unpacked_stack[id] or {}

    for column, meta in pairs(index_map) do
      local old_value = old_unpacked[column]

      -- deleting old index
      if old_value and old_value ~= unpacked[column] then
        local old_index = redis.call("hget", meta.key, old_value)

        if old_index then
          local old_unpacked_index = cmsgpack.unpack(old_index)

          if #old_unpacked_index == 1 then
            if old_unpacked_index[1] == id then
              redis.call("hdel", meta.key, old_value)
            end
          else
            local update_index = {}
            for i = 1, #old_unpacked_index do
              if old_unpacked_index[i] ~= id then
                table.insert(update_index, old_unpacked_index[i])
              end
            end
            redis.call("hset", meta.key, old_value, msgpack.pack(update_index))
          end
        end
      end

      -- update new index
      if unpacked[column] then
        local current_index = redis.call("hget", meta.key, unpacked[column])

        if current_index then
          local current_unpacked_index = cmsgpack.unpack(current_index)
          local need_update_index = true

          for i = 1, #current_unpacked_index do
            if current_unpacked_index[i] == id then
              need_update_index = false
            end
          end

          if need_update_index then
            table.insert(current_unpacked_index, id)
            redis.call("hset", meta.key, unpacked[column], cmsgpack.pack(current_unpacked_index))
          end
        else
          redis.call("hset", meta.key, unpacked[column], cmsgpack.pack({id}))
        end
      end
    end
  end
end

-- data commit
redis.call("hmset", KEYS[1], unpack(packed_stack))
if need_update_auto_increment then
  redis.call("hset", KEYS[2], auto_increment, last_id)
end

return result
