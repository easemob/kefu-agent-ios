//
//  HLeaveMessageRetrieval.h
//  AgentSDK
//
//  Created by 杜洁鹏 on 2018/6/13.
//  Copyright © 2018年 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgentSDK.h"

@interface HLeaveMessageRetrieval : NSObject
@property (nonatomic, strong) NSDate *created_startDate;
@property (nonatomic, strong) NSDate *created_endDate;
@property (nonatomic, strong) NSString *agentName;
@property (nonatomic, strong) NSString *customerName;
@property (nonatomic, assign) HLeaveMessageType leaveMessageType;
@property (nonatomic, assign) HChannelType channelType;

@end
