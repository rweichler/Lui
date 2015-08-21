local L = require 'luikit'

L.init(_ENV)

local NSLog = L.make_func(L.C.dlsym("NSLog"), L.C.call.ptr2ptr)

local window = UIWindow()
window.Frame = {0,0,320,480}
window.BackgroundColor = UIColor.BlueColor

window:makeKeyAndVisible()

local label = UILabel()
label.Frame = {0, 20, 320, 40}
label.BackgroundColor = UIColor.RedColor
label.TextColor = UIColor.WhiteColor
label.Text = NSString{WithUTF8String = tostring(getmetatable(_ENV))}

window:add{Subview = label}

--print out the errors on the iPhone
--live code updating
