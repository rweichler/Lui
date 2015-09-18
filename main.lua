local L = require 'luikit'

L.init(_ENV)

local function make_label()
    local label = UILabel()
    label.Frame = {0, 20, 320, 40}
    label.BackgroundColor = UIColor.BlackColor
    label.TextColor = UIColor.WhiteColor
    label.Text = NSString{WithUTF8String = tostring(getmetatable(_ENV))}

    return label
end

local function make_root_view_controller()
    local controller = UIViewController()
    controller.View.Frame = {0, 0, 320, 480}
    controller.View:add{Subview = make_label()}
    controller.View.BackgroundColor = UIColor.BlueColor
    return controller
end

local window = UIWindow()
window.Frame = {0, 0, 320, 480}
window.RootViewController = make_root_view_controller()
window:makeKeyAndVisible()
