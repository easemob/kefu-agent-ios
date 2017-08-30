//
//  HDNetworkManager.h
//  AgentSDK
//
//  Created by afanda on 4/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"
#import "UserWaitModel.h"
#import "HDClient.h"

@interface HDNetworkManager : NSObject

//@property(nonatomic,copy,readonly) NSString *loginUsername; //登录客服用户名
//@property(nonatomic,copy,readonly) NSString *loginPassword; //登录客服密码
@property(nonatomic,copy,readonly) NSString *appkey;
//@property(nonatomic,copy,readonly) NSString *deviceToken;


@property(nonatomic,strong,readonly) UserModel   *currentUser;
@property(nonatomic,strong,readonly) IMUserModel *imUser;

+ (instancetype)sharedInstance;

#pragma mark - 登录退出

/*
 * 登录
 * param    username 客服账号
 * param    password 密码
 * param    isHidingLogin 是否隐身登录
 */
- (void)asyncLoginWithUsername:(NSString *)username
                      password:(NSString *)password
                   hidingLogin:(BOOL)isHidingLogin
                    completion:(void(^)(id responseObject, HDError *error))completion;

/*
 * 退出登录
 */
- (void)asyncLogoutCompletion:(void(^)(HDError *error))completion;

/*
 * 自动登录【再次登录】
 */
- (void)autoLoginCompletion:(void(^)(HDError *error))completion;


#pragma mark - 其他

/*
 * 获取最大接待数
 */
- (void)asyncGetMaxServiceSessionCountCompletion:(void(^)(id responseObject, HDError *error))completion;


#pragma mark - 会话

#pragma mark 普通会话

/*
 * 获取会话列表
 * param conversationType 会话类别
 * param page 页码
 * param otherParameters 
 */
- (void)asyncFetchConversationsWithType:(HDConversationType)type
                                   page:(NSInteger)page
                                  limit:(NSInteger)limit
                        otherParameters:(NSDictionary *)otherParameters
                             completion:(void(^)(NSArray *conversations,HDError *error))completion;


/*
 * 发送消息给会话【包括文字、图片、语音等消息】
 */

- (void)asyncSendMessageWithMessageModel:(MessageModel *)messageModel
                              completion:(void(^)(MessageModel *message,HDError *error))completion;

#pragma mark 同事会话
//获取同事列表
- (void)asyncFetchAllCustomersWithCompletion:(void (^)(id responseObject, HDError *error))completion;

//获取客服的未读消息
- (void)asyncGetAgentUnreadMessagesWithRemoteAgentUserId:(NSString *)remoteUserId parameters:(NSDictionary *)parameters completion:(void (^)(id responseObject, HDError *error))completion;
//同事会话
- (void)aysncGetRemoteAgentUserMessagesWithAgentUserId:(NSString *)userId
                                     remoteAgentUserId:(NSString *)remoteUserId
                                            parameters:(NSDictionary *)parameters
                                            completion:(void(^)(id responseObject,HDError *error))completion;

//标记会话为已读
- (void)asyncFetchMarkReadTagWithRemoteAgentUserId:(NSString*)userId
                                                          parameters:(NSDictionary *)parameters
                                                          completion:(void (^)(id responseObject, HDError *error))completion;
#pragma mark  标签

//获取标签树数据
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

#pragma mark - 待接入
//接入会话
- (void)asyncFetchUserWaitQueuesWithUserId:(NSString*)userId
                                                  completion:(void (^)(id responseObject, HDError *error))completion;
//筛选会话
- (void)asyncScreenWaitQueuesWithParameters:(NSDictionary *)parameters
                                 completion:(void(^)(id responseObjcet ,HDError *errror))completion;


#pragma mark - 通知

#pragma mark - 留言

#pragma mark - 历史会话

#pragma mark - 设置


#pragma mark - POST、GET、PUT

- (NSURLSessionDataTask *)asyncSendPOST:(NSString*)path
                         withParameters:(NSDictionary *)otherParameters
                             completion:(void(^)(id responseObject, HDError *error))completion;


- (void)asyncSendGet:(NSString*)path
      withParameters:(NSDictionary *)otherParameters
          completion:(void (^)(id responseObject, HDError *error))completion;

- (void)asyncSendPUT:(NSString*)path
      withParameters:(NSDictionary *)otherParameters
          completion:(void (^)(id responseObject, HDError *error))completion;



- (void)asyncFetchSessionServicesWithChatGroupId:(NSInteger)chatGroupId
                                       lastSeqId:(int)lastSeqId
                           startSessionTimestamp:(NSTimeInterval)startSessionTimestamp
                                      completion:(void (^)(id responseObject, HDError *error))completion;

- (void)logoff;
- (void)saveUser;
- (BOOL)isAutoLogin;

@end
