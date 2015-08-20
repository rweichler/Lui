#import <UIKit/UIKit.h>
#import <lua/lua.h>
#import <lua/lauxlib.h>

@interface LUIAppDelegate : UIResponder<UIApplicationDelegate>
@end

char *file;

int main(int argc, char *argv[])
{
    file = argv[1];
    for(int i = 2; i < argc; i++) {
        argv[i - 1] = argv[i];
    }
    argc--;
    return UIApplicationMain(argc, argv, nil, NSStringFromClass(LUIAppDelegate.class));
}

@implementation LUIAppDelegate
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    lua_dofile(L, file);
    return true;
}
@end
