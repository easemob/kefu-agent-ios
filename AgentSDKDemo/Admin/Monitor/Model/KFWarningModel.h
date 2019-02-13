//
//  KFWarningModel.h
//  AgentSDKDemo
//
//  Created by afanda on 12/8/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KFWarningModel : NSObject

@property (nonatomic, copy) NSString *agentId;

@property (nonatomic, copy) NSString *agentName;

@property (nonatomic, assign) NSTimeInterval alarmDateTime;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *warningId;

@property (nonatomic, assign) NSInteger superviseLevel;

@property (nonatomic, copy) NSString *ruleName;

@property (nonatomic, copy) NSString *sessionId;

@property (nonatomic, copy) NSString *tenantId;

@property (nonatomic, copy) NSString *visitorId;

@property (nonatomic, copy) NSString *visitorName;

@end
