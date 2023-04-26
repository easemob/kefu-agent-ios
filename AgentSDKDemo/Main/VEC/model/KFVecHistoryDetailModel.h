//
//  KFVecHistoryDetailModel.h
//  AgentSDKDemo
//
//  Created by easemob on 2023/4/26.
//  Copyright © 2023 环信. All rights reserved.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KFVecHistoryDetailModel : JSONModel
@property (nonatomic, copy) NSString<Optional> *callDetails;
@property (nonatomic, copy) NSArray<Optional> *callLogDetails;
@property (nonatomic, assign) NSInteger detailId;
@property (nonatomic, assign) NSInteger tenantId;
@property (nonatomic, copy) NSString<Optional> *channelName;
@property (nonatomic, copy) NSString<Optional> *created;
@property (nonatomic, copy) NSString<Optional> *inviteeId;
@property (nonatomic, copy) NSString<Optional> *inviteeType;
@property (nonatomic, copy) NSString<Optional> *inviterId;
@property (nonatomic, copy) NSString<Optional> *inviterType;
@property (nonatomic, copy) NSString<Optional> *originSystem;
@property (nonatomic, copy) NSString<Optional> *status;
@property (nonatomic, copy) NSString<Optional> *updated;
@property (nonatomic, copy) NSArray<Optional> *recordDetails;


@end

NS_ASSUME_NONNULL_END
