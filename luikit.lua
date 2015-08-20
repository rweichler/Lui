
local C = require 'objc-bindings'

local function make_func(symbol, func)
    return function(arg)
        return func(symbol, arg)
    end
end

local objc_getClass = make_func(C.dlsym("objc_getClass"), C.call.string2ptr)
local sel_getUid = make_func(C.dlsym("sel_getUid"), C.call.string2ptr)
local sel_getName = make_func(C.dlsym("sel_getName"), C.call.ptr2string)
local objc_msgSend = C.objc.msgSend

local R = {}

local function id_index(self, key)
    local result = {}
    setmetatable(result, {
        __call = function(self, obj, tbl)
            local newargs = {obj.__id, key}
            if type(tbl) == "table" then
                for k,v in pairs(tbl) do
                    newargs[2] = newargs[2]..k..":"
                    if type(v) == "table" and v.__id ~= nil then
                        table.insert(newargs, v.__id)
                    else
                        table.insert(newargs, v)
                    end
                end
            end
            newargs[2] = sel_getUid(newargs[2])
            if C.objc.getMethod(newargs[1], newargs[2]) then
                local result = {}
                result.__id = objc_msgSend(table.unpack(newargs))
                setmetatable(result, {
                    __index = id_index
                })
                return result
            else
                return error("method "..sel_getName(newargs[2]).."not found")
            end
        end
    })
    return result
end

R.class = function(classname)
    local self = {}
    self.__id = objc_getClass(classname)
    if self.__id == nil then
        return nil
    end
    setmetatable(self, {
        __index = id_index,
        __call = function(_, arg)
            return self:alloc():init(arg)
        end
    })
    return self
end

local function format_class(str)
    str = "_"..str
    return str:gsub("_.", function(match)
        return match:sub(2, 2):upper()
    end)
end

R.framework = function(prefix, dylib)
    --TODO implement dylib
    local result = {}
    setmetatable(result, {
        __index = function(self, key)
            return R.class(prefix..format_class(key))
        end
    })
    return result
end

return R
