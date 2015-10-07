assert(#KEYS == 3)
assert(#ARGV % 2 == 0)

local auto_increment = "auto_increment"

local data_tbl = KEYS[1]
local info_tbl = KEYS[2]
local index_tbl = KEYS[3]

local records = {}
for i = 1, #ARGV, 2 do
  local id = ARGV[i]
  local data = ARGV[i + 1]

  if id == "auto" then
    id = redis.call("HINCRBY", info_tbl, auto_increment, 1)
    local unpacked = cmsgpack.unpack(data)
    unpacked["id"] = id
    data = cmsgpack.pack(unpacked)
  else
    local ai_id = redis.call("HGET", info_tbl, auto_increment)
    local need_update = false

    if ai_id then
      if tonumber(id) > tonumber(ai_id) then
        need_update = true
      end
    else
      need_update = true
    end

    if need_update then
      redis.call("HSET", info_tbl, auto_increment, id)
    end
  end

  redis.call("HSET", data_tbl, id, data)
  records[#records + 1] = data
end

return records
