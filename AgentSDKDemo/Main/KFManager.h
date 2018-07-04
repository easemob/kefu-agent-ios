//
//  HDManager.h
//  AgentSDKDemo
//
//  Created by afanda on 4/20/17.
//  Copyright © 2017 环信. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "KFConversationsController.h"
#import "WaitQueueViewController.h"
#import "NotifyViewController.h"
#import "ChatViewController.h"
#import "EMHeaderImageView.h"

@interface KFManager : NSObject <HDClientDelegate>
singleton_interface(KFManager);

//当前会话Id
@property(nonatomic,strong) NSString *currentSessionId;

@property (strong, nonatomic) NSDate *lastPlaySoundDate;

@property(nonatomic,assign) AppDelegate *appDelegate;

/**
 当前聊天控制器,进入会话的时候传入
 */
@property(nonatomic,strong) ChatViewController *curChatViewConvtroller;


/**
 当前控制器
 */
@property(nonatomic,strong) UIViewController *curViewController;

@property(nonatomic,assign) BOOL needShowSuperviseTip;

@property(nonatomic,strong) EMHeaderImageView *headImageView;

/**
 当前会话数
 */
@property(nonatomic,assign) NSInteger curConversationNum;


- (void)setTabbarBadgeValueWithAllConversations:(NSMutableArray *)allConversations;

- (void)setNavItemBadgeValueWithAllConversations:(NSMutableArray *)allConversations;

//会话
@property(nonatomic,strong)KFConversationsController *conversation;
//待接入
@property(nonatomic,strong) WaitQueueViewController *wait;
//通知
@property(nonatomic,strong) NotifyViewController *noti;

//@property(nonatomic,strong) HDConversationViewController *homeVC;


- (void)showMainViewController;

- (void)showLoginViewController;

//本地推送使用
- (void)registerLocalNoti;



@end
