//
//  HDLoginObject.h
//  AgentSDK
//
//  Created by afanda on 6/15/17.
//  Copyright © 2017 lyuzhao. All rights reserved.
//
//存储在属性列表可能导致用户的设置被清空
#import <Foundation/Foundation.h>

@interface HDLoginObject : NSObject <NSCoding>

@property (nonatomic, copy) NSString *agentUsername; 

@property (nonatomic, copy) NSString *password;

@property (nonatomic, strong) NSData *cookies;

@property (nonatomic, copy) NSDictionary *httpsToken;

@property (nonatomic, copy) NSString *appkey;

@property (nonatomic, strong) NSData *deviceToken;

@end


#import "UserModel.h"

@interface HDUserManager : NSObject

@property (nonatomic, strong) HDLoginObject *loginObject;

+ (instancetype)sharedInstance;

//删除所有的本地用户缓存
- (void)resetLoginObject;

//登录缓存，用于自动登录

- (void)setValue:(id)value forKey:(NSString *)key;

- (void)saveObject:(HDLoginObject *)obj;


//IM user
- (void)saveIMUser:(IMUserModel *)imUser;

- (IMUserModel *)getIMUserModel;

//agentUser
- (void)saveAgentUser:(UserModel *)agentUser;

- (UserModel *)getAgentUserModel;

@end


