//
//  HomeViewController.h
//  EMCSApp
//
//  Created by dhc on 15/4/9.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UITabBarController

+(id) homeViewController;

@property (nonatomic, strong) UIViewController *currentAdminVC;
@property (nonatomic, assign) int conversationVCUnreadCount;

+(void) homeViewControllerDestory;


- (void)setWaitQueueWithBadgeValue:(NSInteger)badgeValue;
- (void)setNotifyWithBadgeValue:(NSInteger)badgeValue;
- (void)setLeaveMessageWithBadgeValue:(NSInteger)badgeValue;

- (void)didReceiveLocalNotification:(UILocalNotification *)notification;

- (void)setTotalBadgeValue;

- (void)showLeftView;

@end

