//
//  HVisitorManager.h
//  AgentSDK
//
//  Created by 杜洁鹏 on 2020/1/19.
//  Copyright © 2020 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgentSDK.h"
NS_ASSUME_NONNULL_BEGIN

@interface HVisitorManager : NSObject

- (void)addVisitorToBlacklist:(NSString *)aVistorId
               vistorNickname:(NSString *)aVistorNickname
             serviceSessionId:(NSString *)aServiceSessionId
                       reason:(NSString *)aReason
                   completion:(void(^)(HDError *error))aCompletion;

- (void)removeVisitorFromBlacklist:(NSString *)aVistorId
                    vistorNickname:(NSString *)aVistorNickname
                        completion:(void(^)(HDError *error))aCompletion;

- (void)checkVisitorInBlacklist:(NSString *)aVisitorId
                     completion:(void(^)(BOOL isInBlackList, HDError *error))aCompletion;
@end

NS_ASSUME_NONNULL_END
