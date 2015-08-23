local function get_valid(map)
    local valid = {}
    for k, v in pairs(map) do
        table.insert(valid, k)
        table.insert(valid, v)
    end
    return table.concat(valid, ", ")
end

local function makemap(map)
    return {
        __index = function(self, key)
            return self[map[key]]
        end,
        __newindex = function(self, key, value)
            if map[key] then
                self[map[key]] = value
            else
                error("invalid field. valid fields are "..get_valid(map))
            end
        end
    }
end


function mapfields(tbl, map)
    setmetatable(tbl, makemap(map))
end
