//
//  AppDelegate.m
//  EMCSApp
//
//  Created by dhc on 15/4/9.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "AppDelegate.h"
#import "KFBaseNavigationController.h"
#import "AppDelegate+EaseMob.h"
#import "HomeViewController.h"
#import "LoginViewController.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"
#import "DDASLLogger.h"
#import "DXUpdateView.h"
#import "KFLeftViewController.h"
#import "UIAlertView+KFAdd.h"
#import "EmotionEscape.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import <Bugly/Bugly.h>

//#import <wax/wax.h>

@interface AppDelegate () <UIAlertViewDelegate>

@end
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch
    [Bugly startWithAppId:@"ba34667555"];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self easemobApplication:application didFinishLaunchingWithOptions:launchOptions];
    [self ddlogInit];
    application.statusBarStyle = UIStatusBarStyleLightContent;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarTintColor:kNavBarBgColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:18]}];
    if([UIDevice currentDevice].systemVersion.floatValue >= 8.0 && [UINavigationBar conformsToProtocol:@protocol(UIAppearanceContainer)]) {
        [[UINavigationBar appearance] setTranslucent:NO];
    }
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];

    [[UITabBar appearance] setTintColor:RGBACOLOR(0x1b, 0xa8, 0xed, 1)];
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [self launch];
    [self startLogin];
    [self clearCache];

    
    [[EmotionEscape sharedInstance] setEaseEmotionEscapePattern:@"\\[[^\\[\\]]{1,3}\\]"];
    [[EmotionEscape sharedInstance] setEaseEmotionEscapeDictionary:[ConvertToCommonEmoticonsHelper emotionsDictionary]];
    
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
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if(application.applicationState == UIApplicationStateActive){
        if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
            [[KFManager sharedInstance].conversation refreshData];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)startLogin
{
    if ([HDClient sharedClient].isLoggedInBefore) {
        [[KFManager sharedInstance] showMainViewController];
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *username = [userDefaults objectForKey:USERDEFAULTS_LOGINUSERNAME];
        NSString *password = [userDefaults objectForKey:USERDEFAULTS_LOGINPASSWORD];
        if (username.length>0 && password.length > 0) {
            [[HDClient sharedClient] asyncLoginWithUsername:username password:password hidingLogin:NO completion:^(id responseObject, HDError *error) {
                if (error == nil) {
                    [[KFManager sharedInstance] showMainViewController];
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setValue:username forKey:USERDEFAULTS_LOGINUSERNAME];
                    [userDefaults synchronize];
                } else {
                    [self showLoginViewController];
                }
            }];
        } else {
            [self showLoginViewController];
        }
    }
}

- (void)showLoginViewController {
    LoginViewController *loginController = [[LoginViewController alloc] init];
    self.window.rootViewController = [[KFBaseNavigationController alloc] initWithRootViewController:loginController];
    [HomeViewController HomeViewControllerDestory];
    //进入登陆页面,角标清空
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)showHomeViewController {
    KFLeftViewController *leftMenuVC = [[KFLeftViewController alloc] init];
    HomeViewController *homeController = [HomeViewController HomeViewController];
    KFBaseNavigationController *navigationController = [[KFBaseNavigationController alloc] initWithRootViewController:homeController];
    self.drawerController = [[MMDrawerController alloc] initWithCenterViewController:navigationController leftDrawerViewController:leftMenuVC];
    [self.drawerController setMaximumLeftDrawerWidth:KScreenWidth-kHomeViewLeft];
    [self.drawerController setShowsShadow:NO];
    [self.drawerController setRestorationIdentifier:@"MMDrawer"];
    [self.drawerController setMaximumRightDrawerWidth:200.0];
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    self.window.rootViewController = self.drawerController;
}

- (void)launch
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.window.bounds];
    if (isIPhone5) {
        imageView.image = [UIImage imageNamed:@"5-1"];
    }else if(isIPhone4){
        imageView.image = [UIImage imageNamed:@"4-1"];
    }else{
        imageView.image = [UIImage imageNamed:@"6-1"];
    }
    
    UIViewController *viewController = [[UIViewController alloc] init];
    [viewController.view addSubview:imageView];
    
    UIActivityIndicatorView *activi = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(KScreenWidth/2 - 15, 400, 30, 30)];
    [viewController.view addSubview:activi];
    activi.color = [UIColor whiteColor];
    [activi startAnimating];
    self.window.rootViewController = viewController;
}

- (void)ddlogInit
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    //应用程序在系统上保持两周的日志文件
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 14;
    [DDLog addLogger:fileLogger];
}

//================appstore start=================
- (void)updateVersion:(id)dic
{
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSDictionary *updateInfo = (NSDictionary*)dic;
        NSString *version = [updateInfo objectForKey:@"versionCode"];
        NSString *appVersion = [[[NSBundle mainBundle]infoDictionary]valueForKey:@"CFBundleVersion"];
        if ([version compare:appVersion options:NSNumericSearch] ==NSOrderedDescending) {
            DXUpdateView *updateView = [[DXUpdateView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) updateInfo:dic];
            [self.window.rootViewController.view addSubview:updateView];
        }
    }
}
//================appstore end=================

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kShowLoginViewControllerTag) {
        [[KFManager sharedInstance] showLoginViewController];
    } else if (alertView.tag == kTransferScheduleRequestTag) {
        BOOL accept = YES;
        if (buttonIndex == 0) { //拒绝
            accept = NO;
        }
        [[HDClient sharedClient].chatManager answerScheduleWithSessionId:alertView.sessionId accept:accept completion:^(id responseObject, HDError *error) {
            if (error == nil) {
                NSLog(@"操作成功");
            }
        }];
    }
}



- (void)clearCache
{
    NSString *libDir = NSHomeDirectory();
    libDir = [libDir stringByAppendingPathComponent:@"Library"];
    NSString *dbDirectoryPath = [libDir stringByAppendingPathComponent:@"kefuAppFile"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:dbDirectoryPath error:nil];
}
@end
