//
//  HDManager.h
//  AgentSDKDemo
//
//  Created by afanda on 4/20/17.
//  Copyright © 2017 环信. All rights reserved.
//

//管理整个项目

#import <Foundation/Foundation.h>
#import "HDConversationViewController.h"

@interface HDManager : NSObject

//当前会话Id
@property(nonatomic,strong) NSString *currentSessionId;

@property (strong, nonatomic) NSDate *lastPlaySoundDate;

@property(nonatomic,strong) HDConversationViewController *homeVC;

+ (instancetype)shareInstance;

- (void)showMainViewController;

- (void)showLoginViewController;

//本地推送使用

- (void)registerLocalNoti;

@end
