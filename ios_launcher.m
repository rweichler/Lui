#import <UIKit/UIKit.h>
#import <lua/lua.h>
#import <lua/lualib.h>
#import <lua/lauxlib.h>

@interface LUIAppDelegate : UIResponder<UIApplicationDelegate>
@end

int main(int argc, char *argv[])
{
    return UIApplicationMain(argc, argv, nil, NSStringFromClass(LUIAppDelegate.class));
}

#define SIZ 4096

void add_path(lua_State *L, char *buf, const char *cwd, const char *var, const char *ext)
{
    lua_getglobal(L, "package"); //package{}

    lua_pushstring(L, var);
    lua_gettable(L, -2); //package{}, path""

    const char *path = lua_tostring(L, -1);
    lua_pop(L, 1); //package{}

    strcpy(buf, cwd);
    strcat(buf, "/lua/?.");
    strcat(buf, ext);
    strcat(buf, ";");
    strcat(buf, path);

    lua_pushstring(L, var);
    lua_pushstring(L, buf);
    lua_settable(L, -3);

    lua_pop(L, 1);
}

@implementation LUIAppDelegate
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    char buf[SIZ];
    const char *cwd = NSBundle.mainBundle.bundlePath.UTF8String;

    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    
    add_path(L, buf, cwd, "path", "lua");
    add_path(L, buf, cwd, "cpath", "dylib");

    strcpy(buf, cwd);
    strcat(buf, "/lua/main.lua");
    int result = luaL_loadfile(L, buf);
    if(result != LUA_OK) {
        NSLog(@"fucked up opening the file: %s", lua_tostring(L, -1));
        return false;
    }

    result = lua_pcall(L, 0, 0, 0);

    if(result != LUA_OK) {
        NSLog(@"fuckde up calling the file: %s", lua_tostring(L, -1));
    }

    return true;

}
@end
