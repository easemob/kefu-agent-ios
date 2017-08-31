//
//  AppDelegate+HDAppDelegate.m
//  AgentSDKDemo
//
//  Created by afanda on 4/19/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "AppDelegate+HDAppDelegate.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "MainViewController.h"
#import "MBProgressHUD.h"

@implementation AppDelegate (HDAppDelegate)

- (void)hdapplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self registerRemoteNotification];
    NSString *apnsCertName = @"";
#if DEBUG
    apnsCertName = @"push-cert-ios-dev";
#else
    apnsCertName = @"push-cert-ios-20160229";
#endif
    
    HDOptions *option = [[HDOptions alloc] init];
    option.apnsCertName = apnsCertName;
    option.enableConsoleLog = YES;
    [[HDClient sharedClient] initializeSDKWithOptions:option];
    
    [self startAutoLogin];
    
    [[EmotionEscape sharedInstance] setEaseEmotionEscapePattern:@"\\[[^\\[\\]]{1,3}\\]"];
    [[EmotionEscape sharedInstance] setEaseEmotionEscapeDictionary:[ConvertToCommonEmoticonsHelper emotionsDictionary]];
}


- (void)startAutoLogin {
    NSLog(@"登录中 ...");
    if ([HDClient sharedClient].isLoggedInBefore) {
        [self showMainViewController];
    }
}


// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    HDError *error = [[HDClient sharedClient] bindDeviceToken:deviceToken];
    if (error) {
        NSLog(@"error :%@",error.errorDescription);
    } else {
        NSLog(@"绑定成功");
    }
}

// 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.failToRegisterApns", Fail to register apns)
                                                    message:error.description
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

// 注册推送
- (void)registerRemoteNotification{
#if !TARGET_IPHONE_SIMULATOR
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    //注册APNs推送
    [application registerForRemoteNotifications];
    UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound |   UIUserNotificationTypeAlert;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
    [application registerUserNotificationSettings:settings];
#endif
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    HDManager *manager = [HDManager shareInstance];
    if (manager.homeVC) {
        [manager.homeVC didReceiveLocalNotification:notification];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
}



@end
