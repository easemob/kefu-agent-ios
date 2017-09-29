//
//  AppDelegate.h
//  EMCSApp
//
//  Created by dhc on 15/4/9.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDrawerController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, HDClientDelegate>

@property (strong, nonatomic) UIWindow *window;


@property(nonatomic,strong) MMDrawerController *drawerController;


- (void)showHomeViewController;

- (void)showLoginViewController;

@end

