//
//  KFVecCallHistoryModel.h
//  AgentSDKDemo
//
//  Created by easemob on 2023/4/25.
//  Copyright © 2023 环信. All rights reserved.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface KFVecCallHistoryModel : JSONModel
@property (nonatomic, copy) NSString<Optional> *agentUserId;
@property (nonatomic, copy) NSArray<Optional> *agentUserSet;
@property (nonatomic, assign) NSInteger callId;
@property (nonatomic, assign) NSInteger callType;
@property (nonatomic, copy) NSString<Optional> *createDatetime;
@property (nonatomic, copy) NSDictionary<Optional> *customer;
@property (nonatomic, assign) NSInteger enquiry;
@property (nonatomic, copy) NSString<Optional> *enquiryComment;
@property (nonatomic, copy) NSString<Optional> *enquiryDes;
@property (nonatomic, copy) NSString<Optional> *hangUpReason;
@property (nonatomic, copy) NSString<Optional> *hangUpUserType;
@property (nonatomic, assign) NSInteger multiCall;
@property (nonatomic, copy) NSString<Optional> *originType;
@property (nonatomic, copy) NSArray<Optional> *queueSet;
@property (nonatomic, copy) NSString<Optional> *ringDatetime;
@property (nonatomic, assign) NSInteger ringingDuration;
@property (nonatomic, copy) NSString<Optional> *rtcSessionId;
@property (nonatomic, copy) NSString<Optional> *sourceType;
@property (nonatomic, copy) NSString<Optional> *state;
@property (nonatomic, copy) NSString<Optional> *stopDatetime;
@property (nonatomic, copy) NSString<Optional> *techChannelId;
@property (nonatomic, copy) NSString<Optional> *techChannelName;
@property (nonatomic, copy) NSString<Optional> *techChannelType;
@property (nonatomic, copy) NSString<Optional> *tenantId;
@property (nonatomic, copy) NSString<Optional> *videoDuration;
@property (nonatomic, copy) NSString<Optional> *videoStartDatetime;
@property (nonatomic, copy) NSDictionary<Optional> *visitorUser;
@property (nonatomic, copy) NSString<Optional> *waitDuration;


@end

NS_ASSUME_NONNULL_END
