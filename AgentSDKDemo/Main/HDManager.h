//
//  HDManager.h
//  AgentSDKDemo
//
//  Created by afanda on 4/20/17.
//  Copyright © 2017 环信. All rights reserved.
//

//管理整个项目

#import <Foundation/Foundation.h>

@interface HDManager : NSObject

//当前会话Id
@property(nonatomic,strong) NSString *currentSessionId;

+ (instancetype)shareInstance;

- (void)showMainViewController;

- (void)showLoginViewController;

@end
