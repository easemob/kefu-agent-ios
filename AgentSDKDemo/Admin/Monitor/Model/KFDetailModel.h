//
//  KFDetailModel.h
//  AgentSDKDemo
//
//  Created by afanda on 12/7/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KFStatuLabel.h"
@interface KFDetailModel : NSObject

//平均会话时长
@property (nonatomic, assign) NSInteger avg_session_time;

//当前会话数
@property (nonatomic, assign) NSInteger current_session_count;

//首次登陆时间
@property (nonatomic, copy) NSString *first_login_time_of_today;

//最大会话数
@property (nonatomic, assign) NSInteger max_session_count;

//昵称
@property (nonatomic, copy) NSString *nickname;

//已结束会话数
@property (nonatomic, assign) NSInteger session_terminal_count;

//客服状态
@property (nonatomic, copy)  NSString *state;

@property (nonatomic, copy) NSString *user_id;

@property (nonatomic, copy) NSString *username;

@property (nonatomic, assign) HDAgentLoginStatus kfState;
@property (nonatomic, assign) HDVECAgentLoginStatus vecState;
@end
