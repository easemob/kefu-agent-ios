//
//  HDLeaveMsgManager.h
//  AgentSDK
//
//  Created by afanda on 5/19/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDLeaveMessage.h"

@interface HDLeaveMsgManager : NSObject

/**
 留言总数
 */
@property(nonatomic,assign) NSInteger totalCount;


/**
 当前pageSize下的页数
 */
@property(nonatomic,assign) NSInteger totalPage;

/**
 获取不同状态的留言列表【例如：未处理,处理中,已处理也可自定义】
 
 @param statusId 状态对应的Id【传nil为全部留言】
 @param pageIndex 第几页
 @param pageSize 每页数据个数
 @param parameters 预留参数，暂传nil
 @param completion 完成回调
 */
- (void)asyncGetLeaveMessagesWithStatusId:(NSString *)statusId
                                pageIndex:(NSInteger)pageIndex
                                 pageSize:(NSInteger)pageSize
                               parameters:(NSDictionary *)parameters
                               completion:(void(^)(NSArray <HDLeaveMessage *> *leaveMessages ,HDError *error))completion;


/**
 获取受让人列表

 @param completion 完成回调
 */
- (void)asyncGetAssigneesCompletion:(void(^)(NSArray <UserModel *> *assignees,HDError *error))completion;


/**
 获取留言状态【eg:未处理,处理中,已处理也可自定义】

 @param parameters 预留参数，暂传nil
 @param completion 完成回调
 */
- (void)asyncGetLeaveMsgStatusWithParameters:(NSDictionary *)parameters completion:(void(^)(NSArray <HDStatus *> *statuses ,HDError *error))completion;


/**
 获取留言详情

 @param leaveMsgId 留言id
 @param completion 完成回调
 */
- (void)asyncGetLeaveMsgDetailWithLeaveMsgId:(NSNumber *)leaveMsgId completion:(void(^)(id responseObject,HDError *error))completion;


/**
 获取留言评论

 @param leaveMsgId 留言id
 @param completion 完成回调
 */
- (void)asyncGetLeaveMsgCommentWithLeaveMsgId:(NSString *)leaveMsgId completion:(void(^)(NSArray <HDLeaveMessage *> *comments,HDError *error))completion;

/**
 留言发布评论

 @param leaveMsgId 留言id
 @param text 文字内容
 @param attachments 附件
 */
- (void)asyncPostLeaveMsgCommentWithLeaveMsgId:(NSString *)leaveMsgId text:(NSString *)text attachments:(NSArray <HDAttachment *>*)attachments completion:(void(^)(id responseObject,HDError *error))completion;

/**
 分配留言给user

 @param user 受让人
 @param leaveMsgId leaveMsgId
 @param completion 完成回调
 */
- (void)asyncAssignLeaveMsgWithUser:(UserModel *)user leaveMsgId:(NSString *)leaveMsgId completion:(void(^)(id responseObject,HDError *error))completion;


/**
 取消分配留言给user

 @param user 当前分配人id
 @param leaveMsgId ID
 @param completion 完成回调
 */
- (void)asyncUnAssignLeaveMsgWithUserId:(NSString *)userId leaveMsgId:(NSString *)leaveMsgId completion:(void(^)(id responseObject,HDError *error))completion;

/**
 设置留言状态

 @param statusId 状态id
 @param completion 完成回调
 */
- (void)asyncSetLeaveMsgStatusWithLeaveMsgId:(NSString *)leaveMsgId statusId:(NSString *)statusId completion:(void(^)(id responseObject,HDError *error))completion;

#pragma mark - 上传

/**
 上传附件
 
 @param imageData 图片数据
 @param completion 完成回调(附件实例)
 */
- (void)asyncUploadImageWithFile:(NSData*)imageData
                           completion:(void (^)(HDAttachment *attachment, HDError *error))completion;



@end
