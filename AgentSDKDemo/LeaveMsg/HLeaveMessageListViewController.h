//
//  HLeaveMessageListViewController.h
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/6/13.
//  Copyright © 2018年 环信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AgentSDK/AgentSDK.h>


@interface HLeaveMessageListViewController : UIViewController
@property (nonatomic, assign) HLeaveMessageType type;
@property (nonatomic, assign) BOOL isCustom; // 是否是自定义
@property (nonatomic, assign) BOOL isUndistributed; // 是否是未分配
@end
