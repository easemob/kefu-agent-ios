//
//  MessageModel.h
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgentSDKTypes.h"
#import "HDBaseMessageBody.h"
#import "HDChatUser.h"

#define MESSAGE_ID @"msgId"
#define MESSAGE_CONID @"chatGroupId"
#define MESSAGE_FROM @"from"
#define MESSAGE_TO @"to"
#define MESSAGE_MESSAGETYPE @"messageType"
#define MESSAGE_BODYTYPE @"type"
#define MESSAGE_BODYMSG @"msg"
#define MESSAGE_CREATE @"createDateTime"
#define MESSAGE_TIME @"timestamp"
#define MESSAGE_SESSIONSERVICEID @"sessionServiceId"
#define MESSAGE_SESSIONSERVICESEQID @"sessionServiceSeqId"
#define MESSAGE_TENANTID @"tenantId"
#define MESSAGE_CHATGROUPSEQID @"chatGroupSeqId"




@interface HDMessage : NSObject

/**
 聊天类型
 */
@property (nonatomic, assign) HDChatType chatType;

/**
 消息唯一id
 */
@property (nonatomic, copy) NSString *messageId;

/**
 会话唯一id
 */
@property (nonatomic) NSInteger conversationId;


/**
 发送方
 */
@property (nonatomic, copy) NSString *from;

/**
 接受方
 */
@property (nonatomic, copy) NSString *to;

/**
 消息状态
 */
@property (nonatomic) HDMessageDeliveryState status;

/**
 消息体
 */
@property (nonatomic, strong) HDBaseMessageBody *nBody;


/**
 是否是发送者
 */
@property (nonatomic) BOOL isSender;


/**
 客户端时间戳
 */
@property (nonatomic) NSTimeInterval localTime;


/**
 时间戳
 */
@property (nonatomic) long long timestamp;

//文字高度
@property (nonatomic, assign) CGSize textSize;


@property (nonatomic, strong) MessageExtModel *ext;

@property (nonatomic, copy) NSString *tenantId;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic) NSInteger sessionServiceSeqId;
@property (nonatomic, strong) HDChatUser *fromUser;
@property (nonatomic, strong) HDChatUser *toUser;
@property (nonatomic) NSInteger chatGroupSeqId;
@property (nonatomic, assign) NSInteger chatGroupId;


@property (nonatomic, copy) NSString *createDes;
@property (nonatomic, copy) NSString *timeDes;


@property (nonatomic) HDMessageBodyType type;

//image
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *thumbnailImage;

//audio
@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, copy) NSString *remotePath;
@property (nonatomic) NSInteger time;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL isPlayed;

@property (nonatomic, strong) NSString *messageType;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 客服同事
 */
- (instancetype)initWithSessionId:(NSString *)sessionId to:(NSString *)to messageBody:(HDBaseMessageBody *)body;


- (instancetype)initWithDictionary:(NSDictionary *)dictionary fromDB:(BOOL)db;

// 更新消息
- (void)updateWithDictionary:(NSDictionary *)dictionary;
@end








