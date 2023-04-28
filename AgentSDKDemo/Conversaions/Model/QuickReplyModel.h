//
//  QuickReplyModel.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/17.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

#define QUICKREPLY_AGENTUSERID @"agentUserId"
#define QUICKREPLY_GROUPTYPE @"groupType"
#define QUICKREPLY_SHOWCUTMESSAGEGROUPID @"shortcutMessageGroupId"
#define QUICKREPLY_TENANTID @"tenantId"
#define QUICKREPLY_SHORTCUTMESSAGEGROUPNAME @"shortcutMessageGroupName"

#define QUICKREPLYMESSAGE_GROUPID @"groupId"
#define QUICKREPLYMESSAGE_MESSAGE @"message"
#define QUICKREPLYMESSAGE_SHOWCUTMESSAGEID @"shortcutMessageId"
#define QUICKREPLYMESSAGE_TENANTID @"tenantId"
#define QUICKREPLYMESSAGE_CREATEDATETIME @"createDateTime"
#define QUICKREPLYMESSAGE_LASTUPDATEDATETIME @"lastUpdateDateTime"

//快速回复消息
@interface QuickReplyModel : NSObject

@property (copy ,nonatomic) NSString *agentUserId;
@property (nonatomic, copy) NSString *brief;
@property (nonatomic, strong) NSDictionary *children;
@property (nonatomic, copy) NSString *groupType;
@property (nonatomic, copy) NSString *shortcutMessageGroupId;
@property (nonatomic, copy) NSString *tenantId;
@property (nonatomic, copy) NSString *shortcutMessageGroupName;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

//快速回复消息组
@interface QuickReplyMessageModel : NSObject

@property (nonatomic, copy) NSString *tenantId;
@property (nonatomic, copy) NSString *phrase;
@property (nonatomic, copy) NSString *Id;
@property (copy ,nonatomic) NSString *agentUserId;
@property (nonatomic, copy) NSArray *brief;
@property (nonatomic, copy) NSArray *children;
@property (nonatomic, strong) NSMutableArray *childrenArray;
@property (assign, nonatomic) NSInteger deleted;
@property (assign, nonatomic) NSInteger leaf;
@property (assign, nonatomic) NSInteger seq;
@property (assign, nonatomic) NSInteger parentId;
@property (assign, nonatomic) NSTimeInterval createDateTime;
@property (assign, nonatomic) NSTimeInterval lastUpdateDateTime;
@property (nonatomic) BOOL isOpen;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)getModelDictionary;

@end
