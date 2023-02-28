//
//  HDWaitUser.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/18.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

#define USERWAIT_CREATETIME @"createDateTime"
#define USERWAIT_LASTTIME @"lastUpdateDateTime"
#define USERWAIT_SESSIONID @"serviceSessionId"
#define USERWAIT_USERNAME @"userName"
#define USERWAIT_QUEUEID @"userWaitQueueId"
#define USERWAIT_USERID @"visitorUserId"
#define USERWAIT_LASTMSG @"lastChatMessage"

//待接入用户
@interface HDWaitUser : NSObject

@property (nonatomic, copy) NSString *createDateTime;
@property (nonatomic, copy) NSString *lastUpdateDateTime;
@property (nonatomic, copy) NSString *serviceSessionId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userWaitQueueId;
@property (nonatomic, copy) NSString *visitorUserId;

@property (nonatomic, copy) NSString *searchWord;

@property (nonatomic, strong) HDMessage *lastMessage;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
