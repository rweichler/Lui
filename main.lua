#!bin/lua

local L = require 'luikit'
local C = require 'objc-bindings'

local NS = L.framework("NS", "Foundation")
--local UI = L.framework("UI", "UIKit")

local function str(str)
    return NS.String{WithUTF8String = str}
end

local mut = NS.MutableString{WithUTF8String = "lol"}

mut:append{String = str(" wut")}

print(C.convert.ptr2string(mut:UTF8String().__id))


local method = C.objc.getMethod(NS.String.__id, L.sel_getUid("alloc"))

print("types: ", C.objc.getTypesFromMethod(method))

