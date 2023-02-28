//
//  KFVideoDetailModel.h
//  AgentSDKDemo
//
//  Created by houli on 2022/2/22.
//  Copyright © 2022 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDVECVideoDetailModel : NSObject
@property (nonatomic, copy) NSString *callId;
@property (nonatomic, copy) NSString *playbackUrl;
@property (nonatomic, copy) NSString *recordStart;
@property (nonatomic, copy) NSString *recordEnd;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *created;
@property (nonatomic, copy) NSString *sid;
@property (nonatomic, copy) NSString *tenantId;
@property (nonatomic, copy) NSString *updated;

@end

NS_ASSUME_NONNULL_END
