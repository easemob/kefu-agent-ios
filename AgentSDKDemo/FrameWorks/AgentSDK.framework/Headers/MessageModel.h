//
//  MessageModel.h
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessageBodyModel.h"

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

typedef enum {
    kefuMessageDeliveryState_Pending = 0,
    kefuMessageDeliveryState_Delivering,
    kefuMessageDeliveryState_Delivered,
    kefuMessageDeliveryState_Failure
}KefuMessageDeliveryState;



@interface MessageModel : NSObject

@property (copy, nonatomic) NSString *messageId;
@property (nonatomic) NSInteger conversationId;
@property (copy, nonatomic) NSString *from;
@property (copy, nonatomic) NSString *to;
@property (nonatomic) NSTimeInterval timeInterval;
@property (nonatomic) NSTimeInterval createInterval;
@property (strong, nonatomic) MessageBodyModel *body;
@property (strong, nonatomic) MessageExtModel *ext;

@property (nonatomic) NSInteger tenantId;
@property (copy, nonatomic) NSString *sessionId;
@property (nonatomic) NSInteger sessionServiceSeqId;
@property (strong, nonatomic) MessageUserModel *fromUser;
@property (strong, nonatomic) MessageUserModel *toUser;
@property (nonatomic) NSInteger chatGroupSeqId;

@property (copy, nonatomic) NSString *createDes;
@property (copy, nonatomic) NSString *timeDes;

//原有代码属性,到时候需要改造
@property (nonatomic) BOOL isSender;    //是否是发送者
@property (nonatomic) KefuMessageBodyType type;
@property (nonatomic) KefuMessageDeliveryState status;

//image
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *thumbnailImage;

//audio
@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, copy) NSString *remotePath;
@property (nonatomic) NSInteger time;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL isPlayed;


/*
 * 构造消息 
 * @param serviceSessionId 
 * @param userId 
 * @param body
 */
- (instancetype)initWithSessionId:(NSString *)sessionId userId:(NSString *)userId messageBody:(MessageBodyModel *)body ext:(NSDictionary *)ext;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end








