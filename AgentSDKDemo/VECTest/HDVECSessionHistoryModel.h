//
//  HDVECSessionHistoryModel.h
//  AgentSDKDemo
//
//  Created by easemob on 2023/2/16.
//  Copyright © 2023 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDVECSessionHistoryModel : NSObject
@property (nonatomic, copy) NSString<Optional > *agentUserId;
@property (nonatomic, copy) NSArray *agentUserSet;
@property (nonatomic, copy) NSString *callId;
@property (nonatomic, copy) NSString *callType;
@property (nonatomic, copy) NSString *createDatetime;
@property (nonatomic, copy) NSDictionary *customer;
@property (nonatomic, copy) NSString *enquiry;
@property (nonatomic, copy) NSString *enquiryDes;
@property (nonatomic, copy) NSString *multiCall;
@property (nonatomic, copy) NSString *originType;
@property (nonatomic, copy) NSArray *queueSet;
@property (nonatomic, copy) NSString *ringDatetime;
@property (nonatomic, copy) NSString *ringingDuration;
@property (nonatomic, copy) NSString *rtcSessionId;
@property (nonatomic, copy) NSString *sourceType;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *techChannelId;
@property (nonatomic, copy) NSString *techChannelName;
@property (nonatomic, copy) NSString *techChannelType;
@property (nonatomic, copy) NSString *tenantId;
@property (nonatomic, copy) NSString *videoStartDatetime;
@property (nonatomic, copy) NSDictionary *visitorUser;
@property (nonatomic, copy) NSString *waitDuration;

@end

NS_ASSUME_NONNULL_END
