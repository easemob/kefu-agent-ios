//
//  HDChatUser.h
//  AgentSDK
//
//  Created by afanda on 9/8/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDChatUser : NSObject

@property (copy, nonatomic) NSString* nicename;
@property (nonatomic) NSInteger tenantId;
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *userType;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary*)messageUserModelDicDesc;

@end
