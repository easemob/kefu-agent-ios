//
//  HDBaseMessageBody.h
//  AgentSDK
//
//  Created by afanda on 9/7/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgentSDKTypes.h"

#define MESSAGEBODY @"body"
#define MESSAGEBODY_MSGEXT @"ext"


@interface HDBaseMessageBody : NSObject

@property (nonatomic, copy) NSDictionary *msgExt;

/*
 *  消息体类型
 */
@property (nonatomic, readonly) HDMessageBodyType type;


- (NSMutableDictionary *)selfDicDesc;


@end

@interface MessageUserModel : NSObject

@property (nonatomic, copy) NSString * nicename;
@property (nonatomic) NSInteger tenantId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userType;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)messageUserModelDicDesc;

@end

@interface MessageExtMsgtypeModel : NSObject

@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *imgUrl;
@property (nonatomic, copy) NSString *itemUrl;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *orderTitle;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)selfDicDesc;

@end

@interface MessageExtModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *price;

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, strong) MessageExtMsgtypeModel *msgtype;
@property (nonatomic, copy) NSString *type;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)selfDicDesc;
@end


