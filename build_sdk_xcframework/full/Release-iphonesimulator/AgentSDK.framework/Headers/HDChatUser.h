//
//  HDChatUser.h
//  AgentSDK
//
//  Created by afanda on 9/8/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDChatUser : NSObject

@property (nonatomic, copy) NSString * nicename;
@property (nonatomic, copy) NSString * username;
@property (nonatomic) NSInteger tenantId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userType;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)messageUserModelDicDesc;

@end
