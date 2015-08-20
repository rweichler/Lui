#!/usr/bin/env lua

local L = require 'luikit'
local C = require 'objc-bindings'

local NS = L.framework("NS", "Foundation")
local UI = L.framework("UI", "UIKit")

local mut = NS.MutableString{WithUTF8String = "lol"}
local str = NS.String{WithUTF8String = " wut"}

mut:append{String = str}

print(C.convert.ptr2string(mut:UTF8String().__id))
