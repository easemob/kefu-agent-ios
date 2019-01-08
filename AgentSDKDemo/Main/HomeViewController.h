//
//  HomeViewController.h
//  EMCSApp
//
//  Created by dhc on 15/4/9.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UITabBarController

+(id) HomeViewController;

@property (nonatomic, strong) UIViewController *currentAdminVC;
@property (nonatomic, assign) NSInteger conversationVCUnreadCount;

+(void) HomeViewControllerDestory;


- (void)setWaitQueueWithBadgeValue:(NSInteger)badgeValue;
- (void)setConversationWithBadgeValue:(NSInteger)badgeValue;
- (void)setNotifyWithBadgeValue:(NSInteger)badgeValue;
- (void)setLeaveMessageWithBadgeValue:(NSInteger)badgeValue;

- (void)didReceiveLocalNotification:(UILocalNotification *)notification;

- (void)setTotalBadgeValue;

- (void)showLeftView;

@end

