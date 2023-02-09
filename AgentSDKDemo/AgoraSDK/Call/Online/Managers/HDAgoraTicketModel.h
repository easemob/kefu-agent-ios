//
//  HLAgoraTicketModel.h
//  AgentSDK
//
//  Created by houli on 2022/2/18.
//  Copyright © 2022 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDAgoraTicketModel : NSObject
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *callId;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *channel;
@end

NS_ASSUME_NONNULL_END
