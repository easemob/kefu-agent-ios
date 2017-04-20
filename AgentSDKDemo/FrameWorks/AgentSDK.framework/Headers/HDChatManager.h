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

@interface HDChatManager : NSObject
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

#pragma mark - HDConversation

/*
 *  从数据库中获取所有的会话，执行后会更新内存中的会话列表
 *
 *  同步方法，会阻塞当前线程
 *
 *  @result 会话列表<HDConversation>
 */
- (NSArray *)loadAllConversations;

/*
 *  获取一个会话
 *
 *  @param aConversationId  会话ID
 *
 *  @result 会话对象
 */
- (HDConversation *)getConversation:(NSString *)aConversationId;
/*
 *  删除会话
 *
 *  @param aConversationId  会话ID
 *  @param aDeleteMessage   是否删除会话中的消息
 *
 *  @result 是否成功
 */
- (BOOL)deleteConversation:(NSString *)aConversationId
            deleteMessages:(BOOL)aDeleteMessage;

#pragma mark - HDMessage

/* 发送消息
 *
 */
- (void)sendMessageWithMessageModel:(MessageModel *)messageModel
                         completion:(void(^)(id responseObject,HDError *))completion;

/*
 * 获取历史消息
 *
 */











/*
 *  获取消息附件路径, 存在这个路径的文件，删除会话时会被删除
 *
 *  @param aConversationId  会话ID
 *
 *  @result 附件路径
 */
- (NSString *)getMessageAttachmentPath:(NSString *)aConversationId;

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
 *  @param aMessage            消息
 */
- (void)resendMessage:(MessageModel *)aMessage
             progress:(void (^)(int progress))aProgressCompletion
           completion:(void (^)(MessageModel *message,
                                HDError *error))aCompletion;

@end
