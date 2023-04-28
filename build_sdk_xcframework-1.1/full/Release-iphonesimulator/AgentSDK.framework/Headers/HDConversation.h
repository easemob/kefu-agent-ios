//
//  HDConversation.h
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgentSDKTypes.h"
#import "UserModel.h"
#import "HDMessage.h"

#define CONVERSATION_ID @"chatGroupId"
#define CONVERSATION_UNREAD @"unReadMessageCount"
#define CONVERSATION_SERVICEID @"serviceSessionId"
#define CONVERSATION_LASTMESSAGE @"lastChatMessage"
#define CONVERSATION_CREATETIME @"createDateTime"
#define CONVERSATION_LATEST_MESSAGE_TIME @"visitorLastMessageTime"


@interface HDConversation : NSObject

@property (nonatomic, copy) NSString *conversationId;
@property (nonatomic, assign) int unreadCount;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, strong) UserModel *chatter;
@property (nonatomic, strong) VisitorUserModel *vistor;
@property (nonatomic, strong) HDMessage *lastMessage;
@property (nonatomic, assign) long long createDateTime;
@property (nonatomic, assign) HDConversationModelType type;
@property (nonatomic, copy) NSString *originType;
@property (nonatomic, copy) NSString *techChannelId;
@property (nonatomic, copy) NSString *techChannelName;
@property (nonatomic, copy) NSString *serviceNumber;
@property (nonatomic, copy) NSString *createDatetime;
@property (nonatomic, assign) NSInteger chatGroupId;
@property (nonatomic, copy) NSString *startDateTime;
@property (nonatomic, strong) NSDate *createDate;
@property (nonatomic, copy) NSString *searchWord;
@property (nonatomic, copy) NSString *chatNicename;
@property (nonatomic, copy) NSString *chatTruename;
@property (nonatomic, assign) BOOL isNewTransferedFrom;
@property (nonatomic, assign) long long lasterMessageTime;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
