//
//  AppDelegate.m
//  hyapp
//
//  Created by mac on 16/9/12.
//  Copyright © 2016年 sequel. All rights reserved.
//

#import "AppDelegate.h"
#import "UserGuideViewController.h"
#import "ViewController.h"
#import "WXApi.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.ga
    self.window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"firstLaunch"];
        UserGuideViewController *uc=[[UserGuideViewController alloc]init];
        self.window.rootViewController=uc;
    }else{
        ViewController *view=[[ViewController alloc]init];
        self.window.rootViewController=view;
    }
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window makeKeyAndVisible];
    
    //向微信注册wxd930ea5d5a258f4f
    [WXApi registerApp:@"wxd49f9132693d6bb7"];
    
    return YES;
}
-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    if(self.isFull) return UIInterfaceOrientationMaskAll;//可以旋转
    return UIInterfaceOrientationMaskPortrait;//只竖屏
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WXApi handleOpenURL:url delegate:self];
}
//被废弃的方法. 但是在低版本中会用到.建议写上

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

//新的方法
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    return [WXApi handleOpenURL:url delegate:self];
}

-(void)onResp:(BaseResp *) resp{
    if ([resp isKindOfClass:[PayResp class]]){
        PayResp *response=(PayResp*)resp;
        switch(response.errCode){
            case WXSuccess:
                //服务器端查询支付通知或查询API返回的结果再提示成功
                NSLog(@"支付成功");
                break;
            default:
                NSLog(@"支付失败，retcode=%d",resp.errCode);
                break;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_wxpayoff" object:self userInfo:nil];
}

@end
