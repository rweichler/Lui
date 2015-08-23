

local function makemap(map)
    local valid = {}
    for k, v in pairs(map) do
        table.insert(valid, k)
    end
    valid = table.concat(valid, ", ")

    return {
        __index = function(self, key)
            return self[map[key]]
        end,
        __newindex = function(self, key, value)
            if map[key] then
                self[map[key]] = value
            else
                error("invalid field. valid fields are "..valid)
            end
        end
    }
end


function mapfields(tbl, map)
    setmetatable(tbl, makemap(map))
end
