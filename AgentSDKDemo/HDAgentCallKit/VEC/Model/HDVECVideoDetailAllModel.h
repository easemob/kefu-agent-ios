//
//  KFVideoDetailAllModel.h
//  AgentSDKDemo
//
//  Created by houli on 2022/6/28.
//  Copyright © 2022 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDVECVideoDetailAllModel : NSObject
@property (nonatomic, copy) NSString *tenantId;
@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *inviterId;
@property (nonatomic, copy) NSString *inviterType;
@property (nonatomic, copy) NSString *inviteeId;
@property (nonatomic, copy) NSString *inviteeType;
@property (nonatomic, copy) NSString *created;
@property (nonatomic, copy) NSString *updated;
@property (nonatomic, copy) NSArray *callDetails;
@property (nonatomic, copy) NSArray *recordDetails;

@end

NS_ASSUME_NONNULL_END
