//
//  HDVECTicketModel.h
//  AgentSDKDemo
//
//  Created by easemob on 2023/2/14.
//  Copyright © 2023 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDVECTicketModel : NSObject
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, assign) NSUInteger callId;
@property (nonatomic, copy) NSString *channel;
@property (nonatomic, copy) NSString *niceName;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *trueName;
@property (nonatomic, assign) NSUInteger uid;
@end

NS_ASSUME_NONNULL_END
