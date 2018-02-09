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

@property(nonatomic,strong) UIViewController *currentAdminVC;

+(void) HomeViewControllerDestory;

+(NSString*) currentBadgeValue;

- (void)setConversationUnRead:(BOOL)aFlag;

- (void)setConversationWithBadgeValue:(NSString*)badgeValue;

- (void)setWaitQueueUnRead:(BOOL)aFlag;

- (void)setWaitQueueWithBadgeValue:(NSString*)badgeValue;

- (void)setNotifyUnRead:(BOOL) aFlag;

- (void)setNotifyWithBadgeValue:(NSString*)badgeValue;

- (void)setLeaveMessageWithBadgeValue:(NSString*)badgeValue;

- (void)didReceiveLocalNotification:(UILocalNotification *)notification;

- (void)messagesDidReceive:(NSArray *)aMessages;

- (void)setCustomerWithBadgeValue:(NSString *)badge;

- (void)setTotalBadgeValue;

- (void)showLeftView;

@end

