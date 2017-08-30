//
//  HDChatManager.h
//  AgentSDK
//
//  Created by afanda on 4/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDChatManagerDelegate.h"
#import "HDConversation.h"
#import "HDHistoryRequestBody.h"

/**
 会话模块
 */
@interface HDChatManager : NSObject

#pragma mark - 普通会话

/**
 *  正在会话的conversationId，只读
 */
@property(nonatomic,copy,readonly) NSString *currentConversationId;

/*
 * 连接状态
 */
@property(nonatomic,assign,readonly) BOOL currentState;

#pragma mark - Delegate

/*
 *  添加回调代理
 *
 *  @param aDelegate  要添加的代理
 *
 */
- (void)addDelegate:(id<HDChatManagerDelegate>)aDelegate;

/*
 *  添加回调代理
 *
 *  @param aDelegate  要添加的代理
 *  @param aQueue     执行代理方法的队列
 */
- (void)addDelegate:(id<HDChatManagerDelegate>)aDelegate
      delegateQueue:(dispatch_queue_t)aQueue;

/*
 *  移除回调代理
 *
 *  @param aDelegate  要移除的代理
 */
- (void)removeDelegate:(id<HDChatManagerDelegate>)aDelegate;


#pragma mark - HDMessage


/*!
 *  发送消息
 *
 *  @param aMessage         消息
 *  @param aProgressBlock   附件上传进度回调block
 *  @param aCompletionBlock      发送完成回调block
 */
- (void)sendMessage:(MessageModel *)aMessage
           progress:(void (^)(int progress))aProgressBlock
         completion:(void (^)(MessageModel *aMessage, HDError *aError))aCompletionBlock;

/*
 *  重发送消息
 *
 *
 *  @param aMessage 消息
 */
- (void)resendMessage:(MessageModel *)aMessage
             progress:(void (^)(int progress))aProgressCompletion
           completion:(void (^)(MessageModel *message,
                                HDError *error))aCompletion;

#pragma mark - conversation


/**
 获取已接入会话的列表

 @param page 页码
 @param limit 每页的数据
 @param completion 完成回调
 */
- (void)asyncLoadConversationsWithPage:(NSInteger)page
                                 limit:(NSInteger)limit
                            completion:(void(^)(NSArray *conversations,HDError *error))completion;

#pragma mark - 同事会话

/**
 同事列表

 @param completion 完成回调
 */
- (void)asyncGetAllCustomersCompletion:(void(^)(id responseObject,HDError *error))completion;

/**
 客服发消息
 
 @param remoteUserId 对方userId
 @param parameters 参数
 @param completion 完成回调
 */
- (void)asyncSendMessageToAgentUserWithRemoteAgentUserId:(NSString *)remoteUserId parameters:(NSDictionary *)parameters completion:(void (^)(id responseObject, HDError *error))completion;


/**
 获取客服未读消息

 @param remoteUserId 客服userId
 @param parameters 参数
 @param completion 完成回调
 */
- (void)asyncGetAgentUnreadMessagesWithRemoteAgentUserId:(NSString *)remoteUserId parameters:(NSDictionary *)parameters completion:(void (^)(id responseObject, HDError *error))completion;

/**
 查询聊天记录【包括已读、未读】

 @param userId 自己的userId
 @param remoteUserId 对方的userId
 @param parameters参数
 @param completion 返回聊天记录
 */
- (void)aysncGetRemoteAgentUserMessagesWithAgentUserId:(NSString *)userId
                                     remoteAgentUserId:(NSString *)remoteUserId
                                            parameters:(NSDictionary *)parameters
                                            completion:(void(^)(id responseObject,HDError *error))completion;



/**
 标记消息为已读

 @param userId 对方userId
 @param parameters 参数
 @param completion 完成回调
 */
- (void)asyncFetchMarkReadTagWithRemoteAgentUserId:(NSString*)userId
                                        parameters:(NSDictionary *)parameters
                                        completion:(void (^)(id responseObject, HDError *error))completion;

#pragma mark  历史会话

- (void)asyncFetchHistoryConversationWithHistoryRequestBody:(HDHistoryRequestBody *)body
                                                       page:(NSInteger)page limit:(NSInteger)limit
                                                 completion:(void (^)(id responseObject, HDError *error))completion;


#pragma mark - 标签

//获取会话标签树
- (void)asyncGetTreeCompletion:(void(^)(id responseObject,HDError *error))completion;

//获取会话标签
- (void)asyncGetSessionSummaryResultsWithSessionId:(NSString *)sessionId
                                        completion:(void(^)(id responseObject,HDError *error))completion;

//获取会话标签备注
- (void)asyncGetSessionCommentWithSessionId:(NSString *)sessionId
                                 completion:(void(^)(id responseObject ,HDError *error))completion;
//修改会话标签备注
- (void)asyncSaveSessionCommentWithSessionId:(NSString *)sessionId
                                  parameters:(NSDictionary *)parameters
                                  completion:(void(^)(id responseObject,HDError *error))completion;
//保存标签
- (void)asyncSaveSessionSummaryResultsWithSessionId:(NSString *)sessionId
                                         parameters:(NSDictionary *)parameters
                                         completion:(void(^)(id responseObject,HDError *error))completion;





@end










