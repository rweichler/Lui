#import <dlfcn.h>
#import <lua/lua.h>
#import <lua/lauxlib.h>
#import <stdio.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <CoreGraphics/CoreGraphics.h>


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

int l_objc_getReturnTypeFromMethod(lua_State *L)
{
    if(lua_gettop(L) == 0 || !lua_islightuserdata(L, 1)) {
        return luaL_error(L, "invalid arguments");
    }

    Method m = lua_touserdata(L, 1);
    char ret[BUFSIZ];
    method_getReturnType(m, ret, BUFSIZ);
    lua_pushstring(L, ret);

    return 1;
}

int l_objc_getTypesFromMethod(lua_State *L)
{
    if(lua_gettop(L) == 0 || !lua_islightuserdata(L, 1)) {
        return luaL_error(L, "invalid arguments");
    }
    Method m = lua_touserdata(L, 1);

    char ret[BUFSIZ];
    method_getReturnType(m, ret, BUFSIZ);
    lua_pushstring(L, ret);

    int count =method_getNumberOfArguments(m);
    for(int i = 0; i < count; i++) {
        char arg[BUFSIZ];
        method_getArgumentType(m, i, arg, BUFSIZ);
        lua_pushstring(L, arg);
    }
    return 1 + count;
}

void *_fixed = NULL;//TERRIBLE HACK

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
            arg = lua_touserdata(L, lua_pos);
            if(_fixed != arg) {
                arg = malloc(sizeof(id));
                *((void **)arg) = lua_touserdata(L, lua_pos);
                //NSLog(@"yo %@", (id)arg);
            }
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

int l_open_library(lua_State *L)
{
    if(!lua_isstring(L, 1)) {
        return luaL_error(L, "argument must be a string");
    }
    const char *name = lua_tostring(L, 1);
    void *lib = dlopen(name, RTLD_NOW);
    if(lib == NULL) {
        return luaL_error(L, "library "LUA_QL("%s")" not found", name);
    }

    lua_pushlightuserdata(L, lib);

    return 1;
}

int l_convert_ptr2string(lua_State *L)
{
    lua_pushstring(L, lua_touserdata(L, 1));
    return 1;
}

int l_type_fix(lua_State *L)
{
    int type = lua_tointeger(L, 1);
    void *ptr;

    if(type == 0) { //CGRect
        CGRect rect = CGRectMake(lua_tonumber(L, 2),
                                 lua_tonumber(L, 3),
                                 lua_tonumber(L, 4),
                                 lua_tonumber(L, 5)
                                );

        ptr = malloc(sizeof(CGRect));
        *((CGRect *)ptr) = rect;
    } else if(type == 1) { //idk
    }

    _fixed = ptr;

    lua_pushlightuserdata(L, ptr);

    return 1;
}

const char *custom_types[] = {
    "CGRect",
    NULL
};

int luaopen_bindings(lua_State *L)
{
    lua_newtable(L);

        lua_pushstring(L, "dlsym");
        lua_pushcfunction(L, l_get_symbol);
        lua_settable(L, -3);

        lua_pushstring(L, "dlopen");
        lua_pushcfunction(L, l_open_library);
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

            lua_pushstring(L, "getTypesFromMethod");
            lua_pushcfunction(L, l_objc_getTypesFromMethod);
            lua_settable(L, -3);
        lua_settable(L, -3);

        lua_pushstring(L, "type");
        lua_newtable(L);

            for(int i = 0; custom_types[i] != NULL; i++) {
                lua_pushstring(L, custom_types[i]);
                lua_pushinteger(L, i);
                lua_settable(L, -3);
            }

            lua_pushstring(L, "fix");
            lua_pushcfunction(L, l_type_fix);
            lua_settable(L, -3);

        lua_settable(L, -3);
    return 1;
}
