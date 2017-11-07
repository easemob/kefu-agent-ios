//
//  HDClient.h
//  AgentSDK
//
//  Created by afanda on 4/6/17.
//  Copyright © 2017 环信. All rights reserved.
//
//  SDK 入口，初始化、模块管理

typedef NS_ENUM(NSUInteger, HDConversationType) {
    HDConversationAccessed = 1,     //已经接入
    HDConversationWaitQueues,       //待接入
    HDConversationHistory,          //历史会话
};

#import <Foundation/Foundation.h>
#import "HDError.h"
#import "HDChatManager.h"
#import "HDWaitManager.h"
#import "HDNotiManager.h"
#import "HDLeaveMsgManager.h"
#import "HDSetManager.h"
#import "HDOptions.h"
#import "HDClientDelegate.h"
#import "HDPushOptions.h"
#import "HDUserManager.h"

/*!
 * SDK Client
 */
@interface HDClient : NSObject

/**
 当前登录IM账号
 */
@property (nonatomic, strong, readonly) NSString *currentIMUsername;

/**
 当前登录的客服账号
 */
@property (nonatomic, strong, readonly) NSString *currentAgentUsername;

/**
 当前登录客服
 */
@property(nonatomic,strong,readonly) UserModel *currentAgentUser;


/**
 当前登录IM
 */
@property(nonatomic,strong) IMUserModel *currentIMUser;

/*
 *  IM SDK版本号
 */
@property (nonatomic, strong, readonly) NSString *imSDKVersion;


/**
 AgentSDK 版本号
 */
@property(nonatomic,strong) NSString *AgentSDKVersion;


/**
 是否已登录(且本地有用户信息)
 */
@property(nonatomic,assign) BOOL isLoggedInBefore;


/**
 是否连接上聊天服务器
 */
@property(nonatomic,assign) BOOL isConnected;


/*!
 *  \~chinese
 *  推送模块
 *
 *  \~english
 *  Apple Push Notification Service setting
 */
@property (nonatomic, strong, readonly) HDPushOptions *hPushOptions;

/*
 会话模块
 */
@property (nonatomic, strong ) HDChatManager *chatManager;

/**
 待接入
 */
@property(nonatomic,strong ) HDWaitManager *waitManager;

/**
 通知中心
 */
@property(nonatomic,strong) HDNotiManager *notiManager;


/**
 留言管理
 */
@property(nonatomic,strong) HDLeaveMsgManager *leaveMsgManager;


@property(nonatomic,strong) HDSetManager *setManager;

/*
 * deviceToken
 */
@property(nonatomic,assign,readonly) NSData *deviceToken;


#pragma mark - initialize

/*
 *  获取SDK实例
 */
+ (instancetype)sharedClient;

/*!
 *  初始化sdk
 *  @param aOptions  设置选项
 */
- (HDError *)initializeSDKWithOptions:(HDOptions *)aOptions;

/*
 *  添加回调代理
 *  @param aDelegate  要添加的代理
 *  @param aQueue     执行代理方法的队列
 */
- (void)addDelegate:(id<HDClientDelegate>)aDelegate delegateQueue:(dispatch_queue_t)aQueue;

/*
 *  移除回调代理
 *  @param aDelegate  要移除的代理
 */
- (void)removeDelegate:(id<HDClientDelegate>)aDelegate;

/*
 *  iOS专用，程序进入后台时，需要调用此方法断开连接
 */
- (void)applicationDidEnterBackground:(id)aApplication;

/*!
 *  iOS专用，程序进入前台时，需要调用此方法进行重连
 */
- (void)applicationWillEnterForeground:(id)aApplication;

/*!
 *  iOS专用，程序在前台收到APNs时，需要调用此方法
 *
 *  @param application  UIApplication
 *  @param userInfo     推送内容
 */
- (void)application:(id)application didReceiveRemoteNotification:(NSDictionary *)userInfo;


#pragma mark - Login

/*
 *  登录客服
 *  @param username        
 *  @param password
 *  @param isHidingLogin
 *  @param completion
 */
- (void)asyncLoginWithUsername:(NSString *)username
                      password:(NSString *)password
                   hidingLogin:(BOOL)isHidingLogin
                    completion:(void(^)(id responseObject, HDError *error))completion;
/*
 *  退出登录
 *  退出的同时绑定的deviceToken
 */
- (void)logoutCompletion:(void(^)(HDError * error))completion;

#pragma mark - APNS

/*!
 *  \~chinese
 *  绑定device token
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aDeviceToken  要绑定的token
 *
 *  @result 错误信息
 */
- (HDError *)bindDeviceToken:(NSData *)aDeviceToken;

/*!
 *  \~chinese
 *  从服务器获取推送属性
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param pError  错误信息
 *
 *  @result 推送属性
 */
- (HDPushOptions *)getPushOptionsFromServerWithError:(HDError **)pError;

/*!
 *  \~chinese
 *  设置推送消息显示的昵称
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aNickname  要设置的昵称
 *
 *  @result 错误信息
 */
- (HDError *)setApnsNickname:(NSString *)aNickname;

/*!
 *  \~chinese
 *  更新推送设置到服务器
 *
 *  同步方法，会阻塞当前线程
 */
- (HDError *)updatePushOptionsToServer:(HDPushOptions *)hPushOptions;

#pragma mark - 注册

/**
 获取图片验证码
 
 @param completion 完成回调
 */
- (void)getVerificationImageCompletion:(void(^)(id responseObject,HDError *error))completion;



/**
 获取邮箱验证码

 @param completion 完成回调
 */
- (void)sendVerificationEmailParameters:(NSDictionary *)parameters completion:(void(^)(id responseObject,HDError *error))completion;


/**
 验证注册信息[尚未短信验证]

 @param paramenters 参数
 @param completion 完成回调
 */
- (void)verifyRegisterInfoWithParameters:(NSDictionary *)paramenters completion:(void(^)(id responseObject ,HDError *error))completion;


/**
 注册用户[已经短信验证]

 @param parameters 参数
 @param completion 完成回调
 */
- (void)registerUserWithParameters:(NSDictionary *)parameters completion:(void(^)(id responseObject,HDError *error))completion;


/**
 重置密码

 @param parameters 参数
 @param completion 完成回调
 */
- (void)resetPasswordWithparameters:(NSDictionary *)parameters completion:(void(^)(id responseObject,HDError *error))completion;


/**
 获取过期信息

 @param completion 完成回调
 */
- (void)getExpiredInformationCompletion:(void(^)(id responseObject,HDError *error))completion;


@end
