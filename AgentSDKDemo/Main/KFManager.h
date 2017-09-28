//
//  HDManager.h
//  AgentSDKDemo
//
//  Created by afanda on 4/20/17.
//  Copyright © 2017 环信. All rights reserved.
//

//管理整个项目

#import <Foundation/Foundation.h>
#import "ConversationsController.h"
#import "WaitQueueViewController.h"
#import "NotifyViewController.h"
#import "LeaveMsgViewController.h"

@interface KFManager : NSObject <HDClientDelegate>

//当前会话Id
@property(nonatomic,strong) NSString *currentSessionId;

@property (strong, nonatomic) NSDate *lastPlaySoundDate;

//会话
@property(nonatomic,strong) ConversationsController *conversation;
//待接入
@property(nonatomic,strong) WaitQueueViewController *wait;
//通知中
@property(nonatomic,strong) NotifyViewController *noti;
//留言
@property(nonatomic,strong) LeaveMsgViewController *leaveMsg;

//@property(nonatomic,strong) HDConversationViewController *homeVC;

+ (instancetype)shareInstance;

- (void)showMainViewController;

- (void)showLoginViewController;

//本地推送使用
- (void)registerLocalNoti;

@end
