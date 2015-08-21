local L = require 'luikit'

local NS = L.framework("NS", "Foundation")
local UI = L.framework("UI", "UIKit")

local NSLog = L.make_func(L.C.dlsym("NSLog"), L.C.call.ptr2ptr)

local window = UI.Window()
window.Frame = {0,0,320,480}
window.BackgroundColor = UI.Color.BlueColor

window:makeKeyAndVisible()

local label = UI.Label()
label.Frame = {20, 20, 280, 40}
label.BackgroundColor = UI.Color.RedColor
label.TextColor = UI.Color.WhiteColor
label.Text = NS.String{WithUTF8String = "Lua mayn"}

window:add{Subview = label}

--print out the errors on the iPhone
--live code updating
