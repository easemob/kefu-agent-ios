//
//  AppDelegate+EaseMob.m
//  EMCSApp
//
//  Created by EaseMob on 15/7/29.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "AppDelegate+EaseMob.h"
#import "HomeViewController.h"
#import <UserNotifications/UserNotifications.h>

@implementation AppDelegate (EaseMob)

- (void)easemobApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSString *apnsCertName = nil;
#if APPSTORE
    #if DEBUG
        apnsCertName = @"kefu_store_dev";
    #else
        apnsCertName = @"kefu_store_dis";
    #endif
    
#else
    
    #if DEBUG
        apnsCertName = @"push-cert-ios-dev";
    #else
        // 证书对应的是 企业账号299 下的push 证书（kefu_pro.p12）
        apnsCertName = @"push-cert-ios-20160229";
    #endif
    
#endif
    NSLog(@"apnsCertName:%@",apnsCertName);
    HDOptions *options = [[HDOptions alloc] init];
    options.apnsCertName = apnsCertName;
    options.enableConsoleLog = YES;
    options.showVisitorInputState = YES;
//    options.kefuRestAddress = @"visitor-kefu.kyemalltest.com";
//    options.kefuRestAddress = @"kefu.dongfeng-renault.com.cn";
//    options.restServer = @"a1-kefu.kyemalltest.com";
//    options.chatServer = @"10.121.224.46";
//    options.chatPort = 16717;
//    options.kefuRestAddress = @"https://sandbox.kefu.easemob.com";
//    options.kefuRestAddress = @"https://helps.live";
    [[HDClient sharedClient] initializeSDKWithOptions:options];
    [self registerRemoteNotification];
    [self registerEaseMobNotification];
    [self setupNotifiers];
    [[EMSDImageCache sharedImageCache] cleanDisk];
}

// 监听系统生命周期回调，以便将需要的事件传给SDK
- (void)setupNotifiers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackgroundNotif:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActiveNotif:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActiveNotif:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidReceiveMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminateNotif:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appProtectedDataWillBecomeUnavailableNotif:)
                                                 name:UIApplicationProtectedDataWillBecomeUnavailable
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appProtectedDataDidBecomeAvailableNotif:)
                                                 name:UIApplicationProtectedDataDidBecomeAvailable
                                               object:nil];
}

#pragma mark - notifiers
- (void)appDidEnterBackgroundNotif:(NSNotification*)notif{
    [[HDClient sharedClient] applicationDidEnterBackground:notif.object];
}

- (void)appWillEnterForeground:(NSNotification*)notif
{
    [[HDClient sharedClient] applicationWillEnterForeground:notif.object];
}

- (void)appDidFinishLaunching:(NSNotification*)notif
{
}

- (void)appDidBecomeActiveNotif:(NSNotification*)notif
{
}

- (void)appWillResignActiveNotif:(NSNotification*)notif
{
}

- (void)appDidReceiveMemoryWarning:(NSNotification*)notif
{
}

- (void)appWillTerminateNotif:(NSNotification*)notif
{
}

- (void)appProtectedDataWillBecomeUnavailableNotif:(NSNotification*)notif
{
}

- (void)appProtectedDataDidBecomeAvailableNotif:(NSNotification*)notif
{

}

#pragma mark - registerEaseMobNotification
- (void)registerEaseMobNotification{
    [self unRegisterEaseMobNotification];
    // 将self 添加到SDK回调中，以便本类可以收到SDK回调
//    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
}



- (void)unRegisterEaseMobNotification{
    
}

#pragma mark - HDChatManagerDelegate


- (void)autoLoginDidCompleteWithError:(EMError *)aError {
    if (aError) {
//        DDLogInfo(@"start auto login failed");
    } else{
//        DDLogInfo(@"start auto login");
    }
}

- (void)userAccountDidLoginFromOtherDevice {
//    [MBProgressHUD show:@"其他设备登录" view:self.window];
    [MBProgressHUD showMessag:@"其他设备登录" toView:self.window];
    [[KFManager sharedInstance] showMainViewController];
}


// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       [[HDClient sharedClient] bindDeviceToken:[self _extractTokenFromRawData:deviceToken]];
    });
}

- (NSString *)_extractTokenFromRawData:(NSData *)deviceToken
{
    
    NSString *token = @"";
    do {
        if (@available(iOS 13.0, *)) {
            if ([deviceToken isKindOfClass:[NSData class]]) {
                const unsigned *tokenBytes = (const unsigned *)[deviceToken bytes];
                token = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                                      ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                                      ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                                      ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
                break;
            }else if ([deviceToken isKindOfClass:[NSString class]]) {
                token = [NSString stringWithFormat:@"%@",deviceToken];
                token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
                token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
                token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
                break;
            }
        }else {
            token = [NSString stringWithFormat:@"%@",deviceToken];
            token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
            token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
            token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
            break;
        }
    } while (0);
    
    return token;
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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if ([HomeViewController homeViewController]) {
        [[HomeViewController homeViewController] didReceiveLocalNotification:notification];
    }
}


// 注册推送
- (void)registerRemoteNotification{
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    
    if (NSClassFromString(@"UNUserNotificationCenter")) {
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError *error) {
            if (granted) {
#if !TARGET_IPHONE_SIMULATOR
                dispatch_async(dispatch_get_main_queue(), ^{
                    [application registerForRemoteNotifications];
                });
#endif
            }
        }];
        return;
    }
    
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    [application registerForRemoteNotifications];
#endif
}


@end
