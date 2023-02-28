//
//  HLeaveMessageManager.h
//  AgentSDK
//
//  Created by 杜洁鹏 on 2018/6/14.
//  Copyright © 2018年 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgentSDK/AgentSDK.h>
#import "HResultCursor.h"
#import "HLeaveMessage.h"
#import "HLeaveMessageComment.h"
#import "HLeaveMessageRetrieval.h"

@interface HLeaveMessageManager : NSObject
@property (nonatomic, strong) NSArray *assignees;
@property (nonatomic, strong) NSArray *leaveMessageTypeAry;

- (void)asyncFetchLeaveMessageTypesCompletion:(void(^)(NSArray *leaveMessageTypeAry, HDError *error))aCompletion;

// 根据类型获取留言数量
- (void)asyncFetchLeaveMessageCountWithType:(HLeaveMessageType)aType
                                 completion:(void(^)(NSInteger count, HDError *))aCompletion;

// 根据类型获取对应留言信息
- (void)asyncFetchLeaveMessagesWithType:(HLeaveMessageType)aType
                                pageNum:(NSInteger)aPageNumber
                               pageSize:(NSInteger)aPageSize
                             completion:(void(^)(HResultCursor *result, HDError *error))aCompletion;

// 获取未分配留言数量
- (void)asyncFetchUndistributedLeaveMessageCountCompletion:(void(^)(NSInteger count, HDError *))aCompletion;

// 获取未分配留言
- (void)asyncFetchUndistributedLeaveMessagesWithPageNum:(NSInteger)aPageNumber
                                               pageSize:(NSInteger)aPageSize
                                             completion:(void(^)(HResultCursor *result, HDError *error))aCompletion;

// 获取留言方式
//- (void)asyncFetchLeaveMessageCreateSourceWithPageNum:(NSInteger)aPageNumber
//                                             pageSize:(NSInteger)aPageSize
//                                           completion:(void(^)(HResultCursor *result, HDError *error))aCompletion;
//
//// 获取留言类别
//- (void)asyncFetchLeaveMessageCategoriesWithPageNum:(NSInteger)aPageNumber
//                                           pageSize:(NSInteger)aPageSize
//                                         completion:(void(^)(HResultCursor *result, HDError *error))aCompletion;

// 获取自定义留言
- (void)asyncFetchCustomLeaveMessageWithLeaveMessageRetrieval:(HLeaveMessageRetrieval *)aRetrieval
                                                      pageNum:(NSInteger)aPageNumber
                                                     pageSize:(NSInteger)aPageSize
                                                   completion:(void(^)(HResultCursor *result, HDError *error))aCompletion;

// 获取可被分配受让人列表
- (void)asyncFetchAssigneeListWithPageNum:(NSInteger)aPageNumber
                                 pageSize:(NSInteger)aPageSize
                               completion:(void(^)(HResultCursor *result, HDError *error))aCompletion;


// 根据留言id获取留言详情
- (void)asyncFetchLeaveMessageInfoWithLeaveMessageId:(NSString *)aLeaveMessageId
                                          completion:(void(^)(HLeaveMessage *leaveMessage, HDError *error))aCompletion;

// 批量分配留言
- (void)asyncAssignLeaveMessagesWithMessageIds:(NSArray *)leaveMesageIds
                                     toAgentId:(NSString *)agentId
                                    completion:(void(^)(HDError *error))aCompletion;

// 批量取消分配
- (void)asyncUnAssignLeaveMessageId:(NSArray *)leaveMesageIds
                         completion:(void(^)(HDError *error))aCompletion;


// 修改消息状态
- (void)asyncSetLeaveMessagesTypeWithMessageId:(NSString *)aLeaveMessageId
                                          type:(HLeaveMessageType)aType
                                    completion:(void(^)(HDError *error))aCompletion;

// 获取留言评论
- (void)asyncFetchCommentsWithLeaveMessageId:(NSString *)aLeaveMessageId
                                     pageNum:(NSInteger)aPageNumber
                                    pageSize:(NSInteger)aPageSize
                                  completion:(void(^)(HResultCursor *cursor, HDError *error))aCompletion;

// 发表留言评论
- (void)asyncSendLeaveMessageCommentWithMessageId:(NSString *)aLeaveMessageId
                                          comment:(NSString *)aComment
                                      attachments:(NSArray *)attachments
                                       completion:(void(^)(HDError *error))aCompletion;

// 上传评论附件
- (void)asyncUpLoadCommentAttachmentWithFilePath:(NSString *)aFilePath
                                        fileName:(NSString *)aFileName
                                        progress:(void (^)(float progress))aProgress
                                      completion:(void(^)(HLeaveMessageCommentAttachment *attachment, HDError *error))aCompletion;

// 上传评论附件
- (void)asyncUploadCommentAttachmentWithData:(NSData *)aData
                                    fileName:(NSString *)aFileName
                                    progress:(void (^)(float progress))aProgress
                                  completion:(void(^)(HLeaveMessageCommentAttachment *attachment, HDError *error))aCompletion;

@end
