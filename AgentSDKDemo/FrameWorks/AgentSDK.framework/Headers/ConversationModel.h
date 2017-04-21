//
//  ConversationModel.h
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UserModel.h"
#import "MessageModel.h"

#define CONVERSATION_ID @"chatGroupId"
#define CONVERSATION_UNREAD @"unReadMessageCount"
#define CONVERSATION_SERVICEID @"serviceSessionId"
#define CONVERSATION_LASTMESSAGE @"lastChatMessage"
#define CONVERSATION_CREATETIME @"createDateTime"

typedef enum {
    conversationModelUserType = 0,
    conversationModelCustomerType,
}conversationModelType;


@interface ConversationModel : NSObject

@property (nonatomic, copy) NSString *conversationId;
@property (nonatomic) NSInteger unreadCount;
@property (nonatomic, copy) NSString *serciceSessionId;
@property (strong, nonatomic) UserModel *chatter;
@property (strong, nonatomic) VisitorUserModel *vistor;
@property (strong, nonatomic) MessageModel *lastMessage;
@property (nonatomic) NSTimeInterval createDateTime;
@property (nonatomic) conversationModelType type;
@property (nonatomic, copy) NSString *originType;
@property (nonatomic, copy) NSString *createDatetime;
@property (nonatomic, assign) NSInteger chatGroupId;
@property(nonatomic,copy) NSString *startDateTime;
@property (strong, nonatomic) NSDate *createDate;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
