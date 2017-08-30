//
//  UserWaitModel.h
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
@interface UserWaitModel : NSObject

@property (copy, nonatomic) NSString *createDateTime;
@property (copy, nonatomic) NSString *lastUpdateDateTime;
@property (copy, nonatomic) NSString *serviceSessionId;
@property (copy, nonatomic) NSString *userName;
@property (copy, nonatomic) NSString *userWaitQueueId;
@property (copy, nonatomic) NSString *visitorUserId;

@property (copy, nonatomic) NSString *searchWord;

@property (strong, nonatomic) MessageModel *lastMessage;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
