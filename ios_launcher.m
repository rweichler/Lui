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

@implementation LUIAppDelegate
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    char cwd[BUFSIZ];
    getcwd(cwd, BUFSIZ);
    NSLog(@"UIDick: cwd: %s", cwd);

    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    int result = luaL_loadfile(L, "Applications/Test.app/main.lua");
    if(result != LUA_OK) {
        NSLog(@"UIDick: fucked up opening the file: %s", lua_tostring(L, -1));
        return false;
    }

    result = lua_pcall(L, 0, 0, 0);

    if(result != LUA_OK) {
        NSLog(@"UIDick: fuckde up calling the file: %s", lua_tostring(L, -1));
    }

    return true;

}
@end


@interface UIDick : NSObject
@end

@implementation UIDick
-(void)lolRect:(CGRect)rect
{
    NSLog(@"UIDick: %@", NSStringFromCGRect(rect));
}
@end
