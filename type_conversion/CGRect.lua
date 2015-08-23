
function lua_to_c(tbl)
    return C.lua_to_c(table.unpack(tbl))
end


local map = {
    x = 1,
    y = 2,
    width = 3,
    height = 4
}

function c_to_lua(ptr)
    local result = table.pack(C.c_to_lua(ptr))
    mapfields(result, map)
    return result
end
