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

static int set_thishit(lua_State *L, CGFloat *val)
{
    CGRect *ptr = lua_touserdata(L, 1);
    switch(lua_gettop(L)) {
        case 1: //get
            lua_pushnumber(L, *val);
            return 1;
        case 2: //set
            *val = lua_tonumber(L, 2);
            return 0;
        default:
            return luaL_error("invalid # of arguments (expected 1 or 2)");
    }
}

#define FUNC(ORIGIN, X)                         \
static int get_##X(lua_State *L)                \
{                                               \
    CGRect *ptr = lua_touserdata(L, 1);         \
    return set_thishit(L, &(ptr->ORIGIN.X));    \
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
