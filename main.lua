local L = require 'luikit'

local NS = L.framework("NS", "Foundation")
local UI = L.framework("UI", "UIKit")

local window = UI.Window()
window.Frame = {0,0,320,480}
window.BackgroundColor = UI.Color:blueColor()

window:makeKeyAndVisible()

local label = UI.Label()
label.Frame = {20, 20, 280, 40}
label.BackgroundColor = UI.Color:clearColor()
label.TextColor = UI.Color:whiteColor()
label.Text = NS.String{WithUTF8String = "Lua mayn"}

window:add{Subview = label}

--print out the errors on the iPhone
----live code updating
