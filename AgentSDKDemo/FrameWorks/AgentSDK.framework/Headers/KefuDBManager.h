//
//  KefuDBManager.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/23.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MESSAGE_TABLE @"CREATE TABLE IF NOT EXISTS `messagetable` (`body` varchar,`chatGroupId` integer,`chatGroupSeqId` integer,`contentType` varchar,`createDateTime` double,`ext` varchar,`fromUser` varchar,`messageType` varchar,`msgId` varchar PRIMARY KEY,`sessionServiceId` varchar,`sessionServiceSeqId` integer,`tenantId` integer,`timestamp` integer,`toUser` varchar,`status` integer)"

#define CONVERSATION_TABLE @"CREATE TABLE IF NOT EXISTS `conversationtable` (`chatGroupId` integer,`createDateTime` double,`serviceSessionId` varchat NOT NULL PRIMARY KEY,`unReadMessageCount` integer,`user` varchar,`type` integer)"

#define KEFUTABLE_MESSAGE @"messagetable"
#define KEFUTABLE_MESSAGE_BODY @"body"
#define KEFUTABLE_MESSAGE_CHATGROUPID @"chatGroupId"
#define KEFUTABLE_MESSAGE_CHATGROUPSEQID @"chatGroupSeqId"
#define KEFUTABLE_MESSAGE_CONTENTTYPE @"contentType"
#define KEFUTABLE_MESSAGE_CREATEDATETIME @"createDateTime"
#define KEFUTABLE_MESSAGE_EXT @"ext"
#define KEFUTABLE_MESSAGE_FROMUSER @"fromUser"
#define KEFUTABLE_MESSAGE_MESSAGETYPE @"messageType"
#define KEFUTABLE_MESSAGE_ID @"msgId"
#define KEFUTABLE_MESSAGE_SESSIONSERVICEID @"sessionServiceId"
#define KEFUTABLE_MESSAGE_SESSIONSERVICESEQID @"sessionServiceSeqId"
#define KEFUTABLE_MESSAGE_TENATID @"tenantId"
#define KEFUTABLE_MESSAGE_TIMESTAMP @"timestamp"
#define KEFUTABLE_MESSAGE_TOUSER @"toUser"
#define KEFUTABLE_MESSAGE_STATUS @"status"

#define KEFUTABLE_CONVERSATION @"conversationtable"
#define KEFUTABLE_CONVERSATION_GROUPID @"chatGroupId"
#define KEFUTABLE_CONVERSATION_CREATETIME @"createDateTime"
#define KEFUTABLE_CONVERSATION_SESSIONID @"serviceSessionId"
#define KEFUTABLE_CONVERSATION_UNREADCOUNT @"unReadMessageCount"
#define KEFUTABLE_CONVERSATION_USER @"user"
#define KEFUTABLE_CONVERSATION_TYPE @"type"


@class MessageModel;
@class ConversationModel;
@interface KefuDBManager : NSObject

+ (instancetype)shareManager;

+ (BOOL) openKefuAPPDatabase;

+ (void) closeKefuAPPDatabase;

#pragma mark - message DBfunction
//增删改查
- (MessageModel*)getMsgByMsgId:(NSString*)msgId;

- (BOOL)replaceMessage:(MessageModel *)message;

- (BOOL)insertMessage:(MessageModel *)message;

- (BOOL)insertMessages:(NSArray *)messages;

- (NSArray *)fetchMessagesForSessionServiceId:(NSString *)sessionServiceId withPageNum:(int)page;

- (MessageModel *)fetchLastMessagesForSessionServiceId:(NSString *)sessionServiceId;

- (int)fetchCountForSessionServiceId:(NSString *)sessionServiceId;

- (BOOL)updateMesage:(MessageModel*)message withMessageId:(NSString*)msgId;

- (BOOL)deleteMessagesById:(NSString *)sessionServiceId;

#pragma mark - conversation DBfunction
//增删查
- (BOOL)insertConversationModel:(ConversationModel *)model;

- (BOOL)insertConversationModels:(NSArray *)models;

- (NSArray *)fetchConversationModelForType:(HDConversationType)type;

- (BOOL)deleteConversation:(HDConversationType)type;

- (BOOL)deleteConversationBySessionId:(NSString*)serciceSessionId;

@end
