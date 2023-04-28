//
//  HDThirdAgentModel.h
//  helpdesk_sdk
//
//  Created by houli on 2022/6/7.
//  Copyright © 2022 hyphenate. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDThirdAgentModel : NSObject

@property (nonatomic, strong) NSString * agentNumber;
@property (nonatomic, strong) NSString * avatar;
@property (nonatomic, strong) NSString * trueName;
@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSString * userNickname;
@property (nonatomic, strong) NSString * userType;
@property (nonatomic, strong) NSString * uid;

@end

NS_ASSUME_NONNULL_END
