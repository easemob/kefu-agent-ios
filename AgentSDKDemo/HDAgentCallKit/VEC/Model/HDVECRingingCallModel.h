//
//  KFRingingCallModel.h
//  AgentSDKDemo
//
//  Created by houli on 2022/6/29.
//  Copyright © 2022 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDVECRingingCallModel : NSObject
@property (nonatomic, copy) NSString *rtcSessionId;
@property (nonatomic, copy) NSString *tenantId;
@property (nonatomic, copy) NSString *techChannelId;
@property (nonatomic, copy) NSString *visitorUserId;
@property (nonatomic, copy) NSString *visitorUserNickName;
@property (nonatomic, copy) NSString *visitorUserName;
@property (nonatomic, copy) NSString *queueId;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *agentUserId;
@property (nonatomic, copy) NSString *startDatetime;
@property (nonatomic, copy) NSString *stopDatetime;
@property (nonatomic, copy) NSString *createDatetime;
@property (nonatomic, copy) NSString *agentUserNiceName;
@property (nonatomic, copy) NSString *techChannelType;
@property (nonatomic, copy) NSString *techChannelName;
@property (nonatomic, copy) NSString *originType;
@property (nonatomic, copy) NSString *callType;
@property (nonatomic, assign) BOOL multiCall;
@property (nonatomic, copy) NSString *extra;
@property (nonatomic, copy) NSString *sourceType;
@property (nonatomic, copy) NSString *hangUpUserType;
@property (nonatomic, copy) NSString *hangUpReason;
@property (nonatomic, copy) NSDictionary *visitorUser;//访客信息
@property (nonatomic, copy) NSString *queueName;
@property (nonatomic, copy) NSString *serviceSessionId;
@property (nonatomic, copy) NSString *agentQueue;
@property (nonatomic, copy) NSString *agentUserData;

@end

NS_ASSUME_NONNULL_END
