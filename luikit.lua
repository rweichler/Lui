local UI = framework["UIKit"]


local button = UI:view()

button.x = 20
button.y = 30
button.width = (UI.screen.width - button.x)/2
button.height = (UI.screen.height - button.y)/2

button.color = UI.color.red

local percent = button.x/UI.screen.width

button:rotate(percent*2*math.pi)

UI.app.window:insert(button)
--UI.app.window:addSubview(button)

function button:press(isPressed)
    
end









_G.objc = {}
_G.framework = {}

objc.id = function(obj)
    local result = {}

    setmetatable(result, {
        __index = function(self, key)
            return obj[key]
        end
    })

    return result
end

objc.getClass = function(classname)
    local objc_getClass = C.func("objc_getClass")

    local result = objc_getClass(classname)
    return objc.id(result, classname)
end

function class(classname)
    local result = objc.getClass(classname)
    setmetatable(result, {
        __call = function(self)
            return self:alloc:init()
        end
    })
    return result
end

function format_class(str)
    str = "_"..str
    --fix underscores
    return str:gsub("_.", function(str)
        return str:sub(2, 2):upper()
    end)
end


function framework(prefix)
    local result = {}
    setmetatable(result, {
        __index = function(self, key)
            return class(prefix..format_class(key))
        end
    })
    return result
end


local UI = framework["UIKit"] = framework("UI")
local NS = framework["Foundation"] = framework("NS")

objc.call = function(self, selector, args)
    local pass = {self, selector}
    for k,v in pairs(args) do
        selector = selector..k
        table.insert(pass, v)
    end
    return objc.msgSend(unpack(pass))
end
