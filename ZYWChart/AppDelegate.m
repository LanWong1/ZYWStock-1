//
//  AppDelegate.m
//  ZYWChart
//
//  Created by 张有为 on 2016/12/17.
//  Copyright © 2016年 zyw113. All rights reserved.
//

#import "AppDelegate.h"
#import "FHHFPSIndicator.h"
#import "LoginVC.h"
#import "LoginVC1.h"
#import "WYLoginVC.h"
@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize  iceTool;
@synthesize  userName;
@synthesize  passWord;
@synthesize  userID;
@synthesize  wpTradeAPIServerCallbackReceiverI;
@synthesize loginVC;
@synthesize loginFlag;
@synthesize  iceQuote;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    //[NSThread sleepForTimeInterval:3.0];
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.loginFlag = 0;
#if defined(DEBUG) || defined(_DEBUG)
    [[FHHFPSIndicator sharedFPSIndicator] show];
#endif

#if NpTradeTest
    LoginVC1* Controller = [[LoginVC1 alloc]init];
#else
    //LoginVC* Controller = [[LoginVC alloc]init];
    WYLoginVC* Controller = [[WYLoginVC alloc]init];
    //Controller.view.frame = self.window.bounds;
#endif
    //Controller.view.backgroundColor = [UIColor whiteColor];
    [self.window setRootViewController:Controller];
    [self.window makeKeyAndVisible];
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if(self.isEable) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
   
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
