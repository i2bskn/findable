--[[

delete.lua
* Findable data delete script of evalsha.

@Author  Ken Iiboshi
@Licence MIT
@URL     https://github.com/i2bskn/findable

@Arguments
* KEYS[1]    Data hash name.
* KEYS[2]    Info hash name.
* KEYS[3..n] Index hash names.
* ARGV[1..n] Delete target ids.

]]

assert(#KEYS >= 2)
assert(#ARGV > 0)

local primary_key = "id"

-- for index calculation
local index_map = {}
local need_index_calculation = false

if #KEYS > 2 then
  need_index_calculation = true

  for i = 3, #KEYS do
    local reversed = string.reverse(KEYS[i])
    local pos = string.find(reversed, ":")
    local name = string.reverse(string.sub(reversed, 1, pos - 1))
    index_map[name] = KEYS[i]
  end
end

local data = redis.call("hmget", KEYS[1], unpack(ARGV))
local delete_count = 0

for i = 1, #data do
  local packed = data[i]

  if packed then
    local unpacked = cmsgpack.unpack(packed)
    local id = tonumber(unpacked[primary_key])

    -- delete indexes
    if need_index_calculation then
      for column, key in pairs(index_map) do
        local value = unpacked[column]

        if value then
          local index = redis.call("hget", key, value)

          if index then
            local unpacked_index = cmsgpack.unpack(index)

            if #unpacked_index == 1 then
              if unpacked_index[1] == id then
                redis.call("hdel", key, value)
              end
            else
              local update_index = {}

              for j = 1, #unpacked_index do
                if unpacked_index[j] ~= id then
                  table.insert(update_index, unpacked_index[j])
                end
              end
              redis.call("hset", key, value, msgpack.pack(update_index))
            end
          end
        end
      end
    end

    -- delete data
    redis.call("hdel", KEYS[1], id)
    delete_count = delete_count + 1
  end
end

return delete_count
