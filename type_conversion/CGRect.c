#include <lua/lua.h>
#include <CoreGraphics/CoreGraphics.h>

static int lua_to_c(lua_State *L)
{
    CGRect *ptr = malloc(sizeof(CGRect));
    *ptr = CGRectMake(
                lua_tonumber(L, 1),
                lua_tonumber(L, 2),
                lua_tonumber(L, 3),
                lua_tonumber(L, 4)
           );

    lua_pushlightuserdata(L, ptr);

    return 1;
}

static int c_to_lua(lua_State *L)
{
    CGRect *ptr = lua_touserdata(L, 1);
    CGRect rect = *ptr;

    lua_pushnumber(L, rect.origin.x);
    lua_pushnumber(L, rect.origin.y);
    lua_pushnumber(L, rect.size.width);
    lua_pushnumber(L, rect.size.height);

    return 4;
}
