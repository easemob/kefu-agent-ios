//
//  AppDelegate+HDAppDelegate.m
//  AgentSDKDemo
//
//  Created by afanda on 4/19/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "AppDelegate+HDAppDelegate.h"

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
}


- (void)startAutoLogin {
    [[HDNetworkManager shareInstance] autoLoginCompletion:^(HDError *error) {
        if (error == nil) {
            [self showMainViewController];
        }
    }];
}




@end
