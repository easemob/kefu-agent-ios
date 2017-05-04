//
//  HDConversation.h
//  AgentSDK
//
//  Created by afanda on 4/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDConversation : NSObject

//会话Id
@property(nonatomic,strong,readonly) NSString *sessionId;

@property(nonatomic,assign,readonly) NSInteger chatGroupId;
 //会话最后一条消息
@property(nonatomic,strong,readonly) MessageModel *latestMessage;

@property(nonatomic,assign,readonly) NSInteger messageCount;


-(instancetype)initWithSessionId:(NSString *)sessionId
                     chatGroupId:(NSInteger)chatGroupId;


/*
 * 加载消息
 */
- (void)loadMessageCompletion:(void(^)(NSArray <MessageModel *> *messages,HDError *error))completion;

/*
 * 加载会话历史消息
 */

- (void)loadHistoryCompletion:(void(^)(NSArray <MessageModel *> *messages,HDError *error))completion;

/*
 * 结束会话
 */
- (void)endConversationWithVisitorId:(NSString *)visitorId sessionId:(NSString *)sessionId parameters:(NSDictionary *)parameters completion:(void(^)(id responseObject,HDError *error))completion;


@end
