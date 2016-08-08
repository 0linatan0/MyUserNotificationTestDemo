//
//  AppDelegate.m
//  MyUserNotificationTestDemo
//
//  Created by 谭丽 on 16/8/8.
//  Copyright © 2016年 linatan. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if(!error)
                              {
                                  NSLog(@"@授权成功");
                              }
                          }];
    
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        NSLog(@"%@",settings);
    }];
    
    NSDictionary *remoteUserInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteUserInfo) {
        NSLog(@"remoteUserInfo:%@",remoteUserInfo);
        //APP未启动，点击推送消息，iOS10下还是跟以前一样在此获取
    }
    center.delegate = self;
    
    [self setUpCategory];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    return YES;
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
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken
{
    NSLog(@"deviceToken:%@",deviceToken);
    NSString *deviceTokenStr = [[[[deviceToken description]
                                 stringByReplacingOccurrencesOfString:@"<" withString:@""]
                                stringByReplacingOccurrencesOfString:@">" withString:@""]
                               stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"deviceTokenStr:%@",deviceTokenStr);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError:%@",error);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSLog(@"willPresentNotification:%@",notification.request.content.title);
    
    // 这里真实需要处理交互的地方
    // 获取通知所带的数据
    NSString *apsContent = [notification.request.content.userInfo objectForKey:@"aps"];
    NSLog(@"%@",apsContent);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    //在没有启动本App时，收到服务器推送消息，下拉消息会有快捷回复的按钮，点击按钮后调用的方法，根据identifier来判断点击的哪个按钮
    NSString *apsContent = [response.notification.request.content.userInfo objectForKey:@"aps"];
    NSLog(@"didReceiveNotificationResponse:%@",response.notification.request.content.title);
    NSLog(@"%@",apsContent);
}

//远程推送APP在前台
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSLog(@"didReceiveRemoteNotification:%@",userInfo);
}

- (void)setUpCategory
{
    UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"enterApp" title:@"进入应用" options:UNNotificationActionOptionForeground];
    
    UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"destructive" title:@"忽略" options:UNNotificationActionOptionDestructive];
    
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"helloIdentifier" actions:@[action1,action2] minimalActions:@[action1,action2] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
    
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObjects:category, nil]];
}

@end
