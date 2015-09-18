function create_window()
    local window = UIWindow()
    window.Frame = UIScreen.MainScreen.Bounds
    window.RootViewController = create_main_vc(window.Bounds)
    return window
end

function create_main_vc(bounds)
    local vc = UIViewController()
    vc.View.Frame = bounds
    vc.View:add{Subview = create_label(bounds)}
    vc.View.BackgroundColor = UIColor.BlueColor
    return vc
end


function create_label(bounds)
    local text = tostring(getmetatable(_ENV))

    local label = UILabel()
    label.x = 0
    label.y = 10
    label.width = bounds.width
    label.height = 10
    label.BackgroundColor = UIColor.BlackColor
    label.TextColor = UIColor.WhiteColor
    label.Text = NSString{WithUTF8String = text}
end




Class.add {
    class = "AppDelegate",
    super = UIResponder,
    interfaces = {
        UIApplicationDelegate
    }
}

AppDelegate:add_method {
    selector = "application:didFinishLaunchingWithOptions:",
    args = { "id", "SEL", "id", "id" },
    result = "BOOL",

    imp = function(self, _cmd, application, launchOptions)
        local window = create_window()
        window:makeKeyAndVisible()
        return true
    end
}

UIApplicationMain(AppDelegate)
