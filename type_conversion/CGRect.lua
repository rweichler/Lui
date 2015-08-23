
function lua_to_c(tbl)
    return C.lua_to_c(table.unpack(tbl))
end

local map = {
    "x",
    "y",
    "width",
    "height"
}

function c_to_lua(ptr)
    local result = table.pack(C.c_to_lua(ptr))
    mapfields(result, map)
    return result
end


--funcmap is {x(), y(), width(), height()}
function get_metatable(funcmap)
    for i = 1, 4 do
        funcmap[map[i]] = funcmap[i]
    end

    return {
        __index = function(self, key)
            local func = funcmap[key]
            if func then
                return func(self)
            end
        end,
        __newindex = function(self, key, value)
            local func = funcmap[key]
            if func then
                return func(self, value)
            else
                error("set invalid field")
            end
        end
    }
end
