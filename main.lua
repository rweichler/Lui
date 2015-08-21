local L = require 'luikit'

L.init(_ENV)


local label = UILabel()
label.Frame = {0, 20, 320, 40}
label.BackgroundColor = UIColor.BlackColor
label.TextColor = UIColor.WhiteColor
label.Text = NSString{WithUTF8String = tostring(getmetatable(_ENV))}

local controller = UIViewController()
controller.View.Frame = {0, 0, 320, 480}
controller.View:add{Subview = label}
controller.View.BackgroundColor = UIColor.BlueColor

local window = UIWindow()
window.Frame = {0, 0, 320, 480}
window.RootViewController = controller
window:makeKeyAndVisible()
