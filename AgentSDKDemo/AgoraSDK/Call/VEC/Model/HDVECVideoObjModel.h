//
//  KFVideoObjModel.h
//  AgentSDKDemo
//
//  Created by houli on 2022/6/27.
//  Copyright © 2022 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDVECVideoObjModel : NSObject
@property (nonatomic, copy) NSString *callId;
@property (nonatomic, copy) NSString *ssId;
@property (nonatomic, copy) NSString *videoEndTime;
@property (nonatomic, copy) NSString *videoStartTime;
@property (nonatomic, copy) NSString *videoType;
@property (nonatomic, copy) NSString *visitorName;
@property (nonatomic, copy) NSString *visitorUserId;

@end

NS_ASSUME_NONNULL_END
