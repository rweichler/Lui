#include <lua/lua.h>
#include <CoreGraphics/CGGeometry.h>

const char *NAME = "CGRect";

int lua_to_c(lua_State *L)
{
    CGRect *ptr = lua_newuserdata(L, sizeof(CGRect));
    *ptr = CGRectMake(
                lua_tonumber(L, 1),
                lua_tonumber(L, 2),
                lua_tonumber(L, 3),
                lua_tonumber(L, 4)
           );
    return 1;
}

#define FUNC(ORIGIN, X)                             \
static int get_##X(lua_State *L)                    \
{                                                   \
    switch(lua_gettop(L)) {                         \
        case 1: /* get */                           \
            CGRect *ptr = lua_touserdata(L, 1);     \
            lua_pushnumber(L, ptr->ORIGIN.X);       \
            return 1;                               \
        case 2: /* set */                           \
            CGRect *ptr = lua_touserdata(L, 1);     \
            ptr->ORIGIN.X = lua_tonumber(L, 2);     \
            return 0;                               \
    }                                               \
    return luaL_error("invalid # of arguments");    \
}

FUNC(origin, x);
FUNC(origin, y);
FUNC(size, width);
FUNC(size, height);

int c_to_lua(lua_State *L)
{
    CGRect *ptr = lua_touserdata(L, 1);
    CGRect rect = *ptr;

    lua_pushnumber(L, rect.origin.x);
    lua_pushnumber(L, rect.origin.y);
    lua_pushnumber(L, rect.size.width);
    lua_pushnumber(L, rect.size.height);

    return 4;
}

int register_metatable(lua_State *L)
{
    return 0;
}
