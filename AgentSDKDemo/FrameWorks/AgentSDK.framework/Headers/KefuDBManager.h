//
//  KefuDBManager.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/23.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MESSAGE_TABLE @"CREATE TABLE IF NOT EXISTS messagetable \
        (\
            msgId  TEXT NOT NULL PRIMARY KEY, \
            sessionServiceId   TEXT,\
            chatGroupId     INTEGER,   \
            tenantId    TEXT,\
            messageType     TEXT, \
            fromUser    TEXT,\
            fromusertype    TEXT,   \
            toUser      TEXT,\
            contenttype     INTEGER,  \
            body        TEXT,\
            ext             TEXT,  \
            chatGroupSeqId  INTEGER,\
            sessionServiceSeqId    INTEGER,  \
            createDateTime  INTEGER,\
            timestamp       INTEGER,   \
            status      INTEGER\
        )"

#define CONVERSATION_TABLE @"CREATE TABLE IF NOT EXISTS conversationtable \
        (\
            sessionServiceId TEXT NOT NULL PRIMARY KEY,\
            userId      TEXT,   unReadMessageCount TEXT,\
            nicename    TEXT,   chatGroupId TEXT, \
            uer         TEXT,   createDateTime  TEXT,\
            lastmsgbody TEXT\
        )"

#define KEFUTABLE_MESSAGE @"messagetable"
#define KEFUTABLE_MESSAGE_BODY @"body"
#define KEFUTABLE_MESSAGE_CHATGROUPID @"chatGroupId"
#define KEFUTABLE_MESSAGE_CHATGROUPSEQID @"chatGroupSeqId"
#define KEFUTABLE_MESSAGE_CONTENTTYPE @"contenttype"
#define KEFUTABLE_MESSAGE_CREATEDATETIME @"createDateTime"
#define KEFUTABLE_MESSAGE_EXT @"ext"
#define KEFUTABLE_MESSAGE_FROMUSER @"fromUser"
#define KEFUTABLE_MESSAGE_MESSAGETYPE @"messageType"
#define KEFUTABLE_MESSAGE_ID @"msgId"
#define KEFUTABLE_MESSAGE_MSGID @"msgId"
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


@class HDMessage;
@class HDConversation;
@interface KefuDBManager : NSObject

+ (instancetype)shareManager;

+ (BOOL) openKefuAPPDatabase;

+ (void) closeKefuAPPDatabase;

#pragma mark - message DBfunction
//增删改查
- (HDMessage *)getMsgByMsgId:(NSString*)msgId;

- (BOOL)replaceMessage:(HDMessage *)message;

- (BOOL)insertMessage:(HDMessage *)message;

- (BOOL)insertMessages:(NSArray *)messages;

//- (NSArray *)fetcMessageModelsForSessionServiceId:(NSString *)sessionServiceId withPageNum:(int)page;

- (HDMessage *)fetchLastMessagesForSessionServiceId:(NSString *)sessionServiceId;

- (int)fetchCountForSessionServiceId:(NSString *)sessionServiceId;

- (BOOL)updateMesage:(HDMessage *)message witMessageModelId:(NSString*)msgId;

- (BOOL)deleteMessagesById:(NSString *)sessionServiceId;

#pragma mark - conversation DBfunction
//增删查
- (BOOL)insertConversationModel:(HDConversation *)model;

- (BOOL)insertConversationModels:(NSArray *)models;

- (NSArray *)fetchConversationModelForType:(HDConversationType)type;

- (BOOL)deleteConversation:(HDConversationType)type;

- (BOOL)deleteConversationBySessionId:(NSString*)serciceSessionId;

//new
- (NSArray *)getMessagesForChatGroup:(NSInteger )chatGrpupId page:(int)page;




@end
