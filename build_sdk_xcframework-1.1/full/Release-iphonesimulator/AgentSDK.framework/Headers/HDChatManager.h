//
//  HDChatManager.h
//  AgentSDK
//
//  Created by afanda on 4/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDChatManagerDelegate.h"
#import "HDConversationManager.h"
#import "HDMediaFile.h"
#import "HDConversation.h"
#import "HDHistoryConversation.h"

/**
 会话模块
 */
@interface HDChatManager : NSObject

#pragma mark - 普通会话

/**
 *  正在会话的conversationId，只读
 */
@property (nonatomic,copy,readonly) NSString *currentConversationId;

/*
 * 连接状态
 */
@property (nonatomic,assign,readonly) BOOL currentState;


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
- (void)sendMessage:(HDMessage *)aMessage
           progress:(void (^)(int progress))aProgressBlock
         completion:(void (^)(HDMessage *aMessage, HDError *aError))aCompletionBlock;

///*
// *  重发送消息
// *
// *
// *  @param aMessage 消息
// */
//- (void)resendMessage:(HDMessage *)aMessage
//             progress:(void (^)(int progress))aProgressCompletion
//           completion:(void (^)(HDMessage *message,
//                                HDError *error))aCompletion;

/*
 *  撤回消息
 *
 *
 *  @param aMessage         需要撤回的消息
 *  @param aCompletion      发送完成回调block, 其中message是撤回的消息，消息被撤回后不会被删除，会在ext中添加扩展，以表明该消息是被撤回的。
 */
- (void)recallMessage:(HDMessage *)aMessage
           completion:(void(^)(HDMessage *message,
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


/**
 回应预调度
 
 @param sessionId sessionId
 
 @param accept yes:接受 no:拒绝
 */
- (void)answerScheduleWithSessionId:(NSString *)sessionId accept:(BOOL)accept
                         completion:(void(^)(id responseObject,HDError *error))completion;

#pragma mark - 同事会话

/**
 客服同事列表
 
 @param completion 完成回调
 */
- (void)asyncGetAllCustomersCompletion:(void(^)(NSArray <HDConversation *> *customers,HDError *error))completion;

/**
 客服同事发消息
 
 @param remoteUserId 对方userId
 @param parameters 参数
 @param completion 完成回调
 */
- (void)asyncSendMessageToAgentUserWithRemoteAgentUserId:(NSString *)remoteUserId parameters:(NSDictionary *)parameters completion:(void (^)(id responseObject, HDError *error))completion __deprecated_msg("Use -customerSendMessage:completion:");



/**
 发送客服消息
 
 @param message message
 @param completion 完成回调
 */
- (void)customerSendMessage:(HDMessage *)message completion:(void(^)(id responseObject,HDError *error))completion;


/**
 获取客服同事未读消息
 
 @param remoteUserId 客服userId
 @param parameters 参数
 @param completion 完成回调
 */
- (void)asyncGetAgentUnreadMessagesWithRemoteAgentUserId:(NSString *)remoteUserId parameters:(NSDictionary *)parameters completion:(void (^)(NSArray <HDMessage *> *messages, HDError *error))completion;


/**
 查询客服同事聊天记录【包括已读、未读】
 
 @param remoteUserId 对方userId
 @param parameters 参数
 @param completion 完成回调
 */
- (void)aysncGetAgentMessagesWithRemoteUserId:(NSString *)remoteUserId
                                   parameters:(NSDictionary *)parameters
                                   completion:(void(^)(NSArray <HDMessage *> *messages,HDError *error))completion;



/**
 标记客服消息为已读
 
 @param userId 对方userId
 @param parameters 参数
 @param completion 完成回调
 */
- (void)asyncMarkMessagesAsReadWithRemoteAgentUserId:(NSString *)userId
                                  lastCreateDateTime:(NSTimeInterval)createDateTime
                                          completion:(void (^)(id responseObject, HDError *error))completion;

#pragma mark 快捷回复

/**
 获取快捷回复
 
 @param completion 完成回调
 */
- (void)getQuickReplyCompletion:(void (^)(id responseObject, HDError *error))completion;


/**
 删除一条快捷回复
 
 @param qrId 快捷回复消息id
 @param completion 完成回调
 */
- (void)deleteQuickReplyWithId:(NSString *)qrId
                    completion:(void (^)(id responseObject, HDError *error))completion;


/**
 修改快捷回复
 
 @param parentId 父节点id
 @param text 修改后的内容
 @param leaf leaf description
 @param qrId 快捷消息id
 @param completion 完成回调
 */
- (void)updateQuickReplyWithParentId:(NSString *)parentId
                                text:(NSString *)text
                                leaf:(NSInteger)leaf
                                qrId:(NSString *)qrId
                          completion:(void (^)(id responseObject, HDError *error))completion;


- (void)addQuickReplyWithParentId:(NSString *)parentId
                             text:(NSString *)text
                             leaf:(NSInteger)leaf
                       completion:(void (^)(id responseObject, HDError *error))completion;


#pragma mark  历史会话


/**
 获取历史会话
 
 @param page 页码
 @param limit 每页的数量
 @param parameters 参数
 @param completion 完成回调
 */
- (void)asyncFetchHistoryConversationWithPage:(NSInteger)page
                                        limit:(NSInteger)limit
                                   parameters:(NSDictionary *)parameters
                                   completion:(void (^)(NSArray *conversations, HDError *error,NSInteger totalNum))completion;

/**
 回呼
 
 @param vistorUserId 回呼用户的userId
 @param completion 完成回调
 */
- (void)asyncFetchCreateSessionWithVistorId:(NSString *)vistorUserId
                                 completion:(void (^)(HDHistoryConversation *history, HDError *error))completion;




/**
 获取历史会话的历史消息
 
 @param sessionServicesId 会话id
 @param page 页码
 @param completion 完成回调
 */
- (void)asyncFetchHistoryMessagesWithSessionServicesId:(NSString *)sessionServicesId
                                                  page:(int)page
                                            completion:(void (^)(id responseObject, HDError *error))completion;


/**
 获取关联列表
 
 @param completion 完成
 */
- (void)getChannelsCompletion:(void(^)(id responseObject,HDError *error))completion;


/**
 上传坐席端内容到服务器
 
 @param content 内容
 @param sessionId 会话id
 @param completion 结束回调
 */
- (void)postContent:(NSString *)content sessionId:(NSString *)sessionId completion:(void(^)(id responseObject,HDError *error))completion;

// 本地打包日志
- (NSString *)zipLog;
@end





