#import <dlfcn.h>
#import <lua5.2/lua.h>
#import <lua5.2/lauxlib.h>
#import <stdio.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

int l_call_string2ptr(lua_State *L)
{
    typedef void * (*func_t)(const char *);
    func_t func = lua_touserdata(L, 1);

    void *result = func(lua_tostring(L, 2));
    if(result == NULL) {
        return 0;
    }

    lua_pushlightuserdata(L, result);
    return 1;
}

int l_call_ptr2string(lua_State *L)
{
    typedef const char * (*func_t)(void *);
    func_t func = lua_touserdata(L, 1);

    const char *result = func(lua_touserdata(L, 2));
    if(result == NULL) {
        return 0;
    }
    lua_pushstring(L, result);
    return 1;
}

int l_call_ptr2ptr(lua_State *L)
{
    typedef void * (*func_t)(void *);
    func_t func = lua_touserdata(L, 1);

    void *result = func(lua_touserdata(L, 2));
    if(result == NULL) {
        return 0;
    }
    lua_pushlightuserdata(L, result);
    return 1;
}

int l_objc_getMethod(lua_State *L)
{
    id self = lua_touserdata(L, 1);
    SEL _cmd = lua_touserdata(L, 2);

    Class class = object_getClass(self);
    BOOL is_meta = class_isMetaClass(class);

    Method m;

    if(is_meta) {
        m = class_getClassMethod(class, _cmd);
    } else {
        m = class_getInstanceMethod(class, _cmd);
    }

    if(m == NULL) {
        return 0;
    }

    lua_pushlightuserdata(L, m);
    return 1;
}

int l_objc_msgSend(lua_State *L)
{
    Method m;

    int results = l_objc_getMethod(L);
    if(results == 0) {
        return 0;
    } else {
        m = lua_touserdata(L, -results);
        lua_pop(L, results);
    }

    id self = lua_touserdata(L, 1);
    SEL _cmd = lua_touserdata(L, 2);

    Class class = object_getClass(self);
    BOOL is_meta = class_isMetaClass(class);

    int arg_count = lua_gettop(L) - 2;

    const char *typeEncoding = method_getTypeEncoding(m);

    NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:typeEncoding];


    int actual_arg_count = sig.numberOfArguments - 2;

    if(actual_arg_count != arg_count) {
        return luaL_error(L, "%c[%s %s]: expected %d args, got %d", is_meta ? '+' : '-', class_getName(class), lua_tostring(L, 2), actual_arg_count, arg_count);
    }

    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];

    [inv setTarget:self];
    [inv setSelector:_cmd];
    for(int i = 0; i < arg_count; i++) {
        char arg_type[BUFSIZ];
        method_getArgumentType(m, i + 2, arg_type, BUFSIZ);

        int lua_pos = i + 3;
        void *arg;
        switch(lua_type(L, lua_pos)) {
        case LUA_TNIL:
            arg = NULL;
        break;
        case LUA_TUSERDATA:
        case LUA_TLIGHTUSERDATA:
            arg = malloc(sizeof(id));
            *((void **)arg) = lua_touserdata(L, lua_pos);
            //NSLog(@"yo %@", (id)arg);
        break;
        case LUA_TSTRING:
            arg = malloc(sizeof(const char *));
            *((const char **)arg) = lua_tostring(L, lua_pos);
        break;
        }

        [inv setArgument:arg atIndex:i+2];
    }

    [inv invoke];

    if(sig.methodReturnLength == 0) {
        return 0;
    } else {
        void **result = malloc(sig.methodReturnLength);

        [inv getReturnValue:result];

        lua_pushlightuserdata(L, *result);

        return 1;
    }
}

int l_get_symbol(lua_State *L)
{
    if(!lua_isstring(L, 1)) {
        return luaL_error(L, "argument must be a string");
    }
    const char *name = lua_tostring(L, 1);
    void *func = dlsym(RTLD_DEFAULT, name);
    if(func == NULL) {
        return luaL_error(L, "symbol "LUA_QL("%s")" not found", name);
    }

    lua_pushlightuserdata(L, func);

    return 1;
}

int l_convert_ptr2string(lua_State *L)
{
    lua_pushstring(L, lua_touserdata(L, 1));
    return 1;
}

int luaopen_bindings(lua_State *L)
{
    lua_newtable(L);

        lua_pushstring(L, "dlsym");
        lua_pushcfunction(L, l_get_symbol);
        lua_settable(L, -3);

        lua_pushstring(L, "call");
        lua_newtable(L);

            lua_pushstring(L, "string2ptr");
            lua_pushcfunction(L, l_call_string2ptr);
            lua_settable(L, -3);

            lua_pushstring(L, "ptr2string");
            lua_pushcfunction(L, l_call_ptr2string);
            lua_settable(L, -3);

            lua_pushstring(L, "ptr2ptr");
            lua_pushcfunction(L, l_call_ptr2ptr);
            lua_settable(L, -3);
        lua_settable(L, -3);

        lua_pushstring(L, "convert");
        lua_newtable(L);

            lua_pushstring(L, "ptr2string");
            lua_pushcfunction(L, l_convert_ptr2string);
            lua_settable(L, -3);
        lua_settable(L, -3);

        lua_pushstring(L, "objc");
        lua_newtable(L);

            lua_pushstring(L, "msgSend");
            lua_pushcfunction(L, l_objc_msgSend);
            lua_settable(L, -3);

            lua_pushstring(L, "getMethod");
            lua_pushcfunction(L, l_objc_getMethod);
            lua_settable(L, -3);
        lua_settable(L, -3);

    return 1;
}
