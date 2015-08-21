
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

R.sel_getUid = sel_getUid
R.C = C
R.make_func = make_func


local lookup_table = {}
lookup_table['{CGRect={CGPoint=dd}{CGSize=dd}}'] = function(arg)
    local x, y, width, height

    local indexed = arg[1] ~= nil
    if indexed then
        if type(arg[1]) == "table" then
            x = arg[1][1]
            y = arg[1][2]
            width = arg[2][1]
            height = arg[2][2]
        elseif type(arg[1]) == "number" or type(arg[1]) == "integer" then
            x = arg[1]
            y = arg[2]
            width = arg[3]
            height = arg[4]
        end
    else
        x = arg.x
        y = arg.y
        width = arg.width
        height = arg.height
    end


    if not (x and y and width and height) then
        return error("malformed CGRect")
    end
    return C.type.CGRect, x, y, width, height
end


local function lua_to_C(arg, typ)
    local func = lookup_table[typ]
    if func then
        return C.type.fix(func(arg))
    end
end

local function fix_args(args, method)
    local types = table.pack(C.objc.getTypesFromMethod(method))
    for i, v in ipairs(args) do
        local fixed = lua_to_C(v, types[i + 1])
        if fixed then
            args[i] = fixed
        end
    end
end

local function C_to_lua(arg, typ)
    return nil
end

local function fix_ret(ret, method)
    local typ = C.objc.getTypesFromMethod(method)

    local fixed = C_to_lua(ret, typ)
    if fixed then
        return fixed
    else
        return ret
    end
end

local id_newindex
local function id_index(self, key)
    do
        local first_char = string.sub(key, 1, 1)
        if string.upper(first_char) == first_char then
            local id = self.__id
            local sel = string.lower(first_char)..string.sub(key, 2, #key)
            local method = C.objc.getMethod(id, sel_getUid(sel))
            if method then
                return self[sel](self)
            else
                return error("method '"..sel.."' not found")
            end
        end
    end


    local result = {}
    setmetatable(result, {
        __call = function(self, obj, tbl)
            local newargs = {obj.__id, key}
            if type(tbl) == "table" then
                for k,v in pairs(tbl) do
                    newargs[2] = newargs[2]..k..":"
                    if type(v) == "table" and v.__id then
                        table.insert(newargs, v.__id)
                    else
                        table.insert(newargs, v)
                    end
                end
            end
            newargs[2] = sel_getUid(newargs[2])
            local method = C.objc.getMethod(newargs[1], newargs[2])
            if method then
                fix_args(newargs, method)
                local result = {}
                result.__id = objc_msgSend(table.unpack(newargs))
                setmetatable(result, {
                    __index = id_index,
                    __newindex = id_newindex
                })
                return result
            else
                return error("method "..sel_getName(newargs[2]).."not found")
            end
        end
    })
    return result
end

id_newindex = function(self, key, value)
    local first_char = string.sub(key, 1, 1)
    if string.upper(first_char) == first_char then
        local tbl = {}
        tbl[key] = value
        return self:set(tbl)
    end

    return rawset(self, key, value)
end

R.class = function(classname)
    local self = {}
    self.__id = objc_getClass(classname)
    if self.__id == nil then
        return nil
    end
    setmetatable(self, {
        __index = id_index,
        __newindex = id_newindex,
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
    local ok, lib = pcall(C.dlopen, "/System/Library/Frameworks/"..dylib..".framework/"..dylib)
    if not ok then
        local ok, lib = pcall(C.dlopen, "/System/Library/PrivateFrameworks/"..dylib..".framework/"..dylib)
        if not ok then
            error("framework '"..dylib.."' not found")
        end
    end
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
