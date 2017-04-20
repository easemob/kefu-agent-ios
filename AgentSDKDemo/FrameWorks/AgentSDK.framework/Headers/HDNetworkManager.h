//
//  HDNetworkManager.h
//  AgentSDK
//
//  Created by afanda on 4/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"

typedef NS_ENUM(NSUInteger, HDConversationType) {
    HDConversationAccessed,     //已经接入
    HDConversationWaitQueues,     //待接入
    HDConversationHistory,      //历史会话
    HDConversationChatHistory   //历史消息
};

@interface HDNetworkManager : NSObject

@property(nonatomic,copy,readonly) NSString *loginUsername; //登录客服用户名
@property(nonatomic,copy,readonly) NSString *loginPassword; //登录客服密码
@property(nonatomic,copy,readonly) NSString *appkey;
@property(nonatomic,copy,readonly) NSString *deviceToken;

@property (strong, nonatomic, readonly) NSMutableDictionary *ossConfig;

@property(nonatomic,strong,readonly) UserModel   *currentUser;
@property(nonatomic,strong,readonly) IMUserModel *imUser;

+ (instancetype)shareInstance;
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

/*
 * 获取最大接待数
 */
- (void)asyncGetMaxServiceSessionCountCompletion:(RequestBlock)completion;

/*
 * 获取已经接入的会话列表
 * param conversationType 会话类别
 * param page 页码
 * param limit 每页数据的条数
 * param otherParameters 其他参数【预留,填写nil】
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


#pragma mark - POST

- (NSURLSessionDataTask *)asyncSendPOST:(NSString*)path
                         withParameters:(NSDictionary *)otherParameters
                             completion:(RequestBlock)completion;



- (void)asyncFetchSessionServicesWithChatGroupId:(NSInteger)chatGroupId
                                       lastSeqId:(int)lastSeqId
                           startSessionTimestamp:(NSTimeInterval)startSessionTimestamp
                                      completion:(void (^)(id responseObject, HDError *error))completion;

- (void)logoff;
- (void)saveUser;
- (BOOL)isAutoLogin;

@end
