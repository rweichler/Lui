


local function make_func(symbol, func)
    return function(arg)
        return func(symbol, arg)
    end
end


local objc_getClass = make_func(C.dlsym("objc_getClass"), C.call.string2ptr)
local object_getClass = make_func(C.dlsym("object_getClass"), C.call.ptr2ptr)
local class_getName = make_func(C.dlsym("class_getName"), C.call.ptr2string)
local sel_getUid = make_func(C.dlsym("sel_getUid"), C.call.string2ptr)
local objc_msgSend = C.objc_msgSend


str = objc_msgSend(objc_getClass("NSString"), sel_getUid("alloc"))

str = objc_msgSend(str, sel_getUid("initWithUTF8String:"), "wut")



mut = objc_msgSend(objc_getClass("NSMutableString"), sel_getUid("alloc"))
mut = objc_msgSend(mut, sel_getUid("initWithUTF8String:"), "lol ")

objc_msgSend(mut, sel_getUid("appendString:"), str)



print(C.convert.ptr2string(objc_msgSend(mut, sel_getUid("UTF8String"))))
