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
@property (nonatomic, copy) NSString *callId;
@property (nonatomic, copy) NSString *created;
@property (nonatomic, copy) NSString *ext;
@property (nonatomic, copy) NSString *fromUserNiceName;
@property (nonatomic, copy) NSString *inviteType;
@property (nonatomic, copy) NSString *inviteeId;
@property (nonatomic, copy) NSString *joinCall;
@property (nonatomic, copy) NSString *joinDate;
@property (nonatomic, copy) NSString *leaveDate;
@property (nonatomic, copy) NSString *updated;

@end

NS_ASSUME_NONNULL_END
