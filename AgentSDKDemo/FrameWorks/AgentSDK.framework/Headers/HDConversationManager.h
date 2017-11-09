//
//  HDConversationManager.h
//  AgentSDK
//
//  Created by afanda on 4/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDConversationManager : NSObject

@property(nonatomic,strong,readonly) NSString *sessionId;

@property(nonatomic,assign,readonly) NSInteger chatGroupId;
 //会话最后一条消息
@property(nonatomic,strong,readonly) HDMessage *latestMessage;

@property(nonatomic,assign,readonly) NSInteger messageCount;

@property(nonatomic,copy) NSString *searchWord;

@property(nonatomic,copy) NSDictionary *lastExtWeichat;

/**
 同一个访客和不同的客服沟通之后，是同一个chatGroupId
 而与每一个客服聊天都会分别有一个sessionId
 */
-(instancetype)initWithSessionId:(NSString *)sessionId chatGroupId:(NSInteger)chatGroupId;


- (instancetype)initWithSessionId:(NSString *)sessionId;

/*
 * 加载消息
 */
- (void)loadMessageCompletion:(void(^)(NSArray <HDMessage *> *messages,HDError *error))completion;

/*
 * 加载会话历史消息
 */
- (void)loadHistoryCompletion:(void(^)(NSArray <HDMessage *> *messages,HDError *error))completion;

#pragma mark - 转接、评价、标签、结束会话

/**
 会话转接客服

 @param remoteUserId 对方userId
 @param completion 完成回调
 */
- (void)transferConversationWithRemoteUserId:(NSString *)remoteUserId completion:(void(^)(id responseObject,HDError *error))completion;

/**
 获取技能组数据
 
 @param completion 完成回调
 */
- (void)getSkillGroupCompletion:(void(^)(id responseObject,HDError *error))completion;

/**
 转接技能组

 @param queueId queueId
 @param completion 完成回调
 */
- (void)transferConversationWithQueueId:(NSString *)queueId completion:(void(^)(id responseObject,HDError *error))completion;


//获取会话标签树
- (void)asyncGetTreeCompletion:(void(^)(id responseObject,HDError *error))completion;

//获取会话标签
- (void)asyncGetSessionSummaryResultsCompletion:(void(^)(id responseObject,HDError *error))completion;

//获取会话标签备注
- (void)asyncGetSessionCommentCompletion:(void(^)(id responseObject ,HDError *error))completion;
//修改会话标签备注
- (void)asyncSaveSessionCommentParameters:(NSDictionary *)parameters
                                  completion:(void(^)(id responseObject,HDError *error))completion;
//保存标签
- (void)asyncSaveSessionSummaryResultsParameters:(NSDictionary *)parameters
                                         completion:(void(^)(id responseObject,HDError *error))completion;

/**
 满意度评价状态
 
 @param completion YES 已经发送过；NO 尚未发送
 */
- (void)satisfactionStatusCompletion:(void(^)(BOOL send,HDError *error))completion;

- (void)sendSatisfactionEvaluationCompletion:(void(^)(BOOL send,HDError *error))completion;

/*
 * 结束会话
 */
- (void)endConversationWithVisitorId:(NSString *)visitorId parameters:(NSDictionary *)parameters completion:(void(^)(id responseObject,HDError *error))completion;

/*
 * 标记已读
 * parameters  预留参数传nil
 */
- (void)markMessagesAsReadWithVisitorId:(NSString *)visitorId parameters:(NSDictionary *)parameters completion:(void(^)(id responseObject,HDError *error))completion;

//消息
- (void)sendMessage:(HDMessage *)aMessage progress:(void (^)(int))aProgressBlock completion:(void (^)(HDMessage *, HDError *))aCompletionBlock;

@end
