//
//  AppDelegate+HDAppDelegate.m
//  AgentSDKDemo
//
//  Created by afanda on 4/19/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "AppDelegate+HDAppDelegate.h"
#import "ConvertToCommonEmoticonsHelper.h"

@implementation AppDelegate (HDAppDelegate)

- (void)hdapplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *appkey = [[HDNetworkManager shareInstance] appkey];
    NSString *apnsCertName = @"";
#if DEBUG
    apnsCertName = @"dev";
#else
    apnsCertName = @"dis";
#endif
    if (appkey != nil && appkey.length > 0 ) {
        HDOptions *option = [[HDOptions alloc] init];
        option.apnsCertName = apnsCertName;
//        option.enableConsoleLog = YES;
        [[HDClient shareClient] initializeSDKWithOptions:option];
    }
    
    [self startAutoLogin];
    
    [[EmotionEscape sharedInstance] setEaseEmotionEscapePattern:@"\\[[^\\[\\]]{1,3}\\]"];
    [[EmotionEscape sharedInstance] setEaseEmotionEscapeDictionary:[ConvertToCommonEmoticonsHelper emotionsDictionary]];
}


- (void)startAutoLogin {
    [[HDNetworkManager shareInstance] autoLoginCompletion:^(HDError *error) {
        if (error == nil) {
            [self showMainViewController];
        }
    }];
}


// 注册推送
- (void)registerRemoteNotification{
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    //iOS8 注册APNS
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    }else{
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
#endif
}




@end
