//
//  HDClient.h
//  AgentSDK
//
//  Created by afanda on 4/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDError.h"
#import "HDChatManager.h"
#import "HDOptions.h"
#import "HDClientDelegate.h"
#import "HDPushOptions.h"

/*
 * 请求返回BLOCK
 * param respponseObject 返回的数据
 * param error 请求失败,返回错误
 */
typedef void(^RequestBlock)(id responseObject, HDError *error);

/*!
 * SDK Client
 */
@interface HDClient : NSObject

/*!
 *  \~chinese
 *  当前登录账号
 */
@property (nonatomic, strong, readonly) NSString *currentUsername;

/*
 *  SDK版本号
 */
@property (nonatomic, strong, readonly) NSString *version;


/*!
 *  \~chinese
 *  推送设置
 *
 *  \~english
 *  Apple Push Notification Service setting
 */
@property (nonatomic, strong, readonly) HDPushOptions *hPushOptions;

/*
 *  聊天模块
 */
@property (nonatomic, strong, readonly) HDChatManager *chatManager;

//@property (nonatomic, strong, readonly)

/*
 * deviceToken
 */
@property(nonatomic,assign) NSData *deviceToken;

/*
 *  获取SDK实例
 */
+ (instancetype)shareClient;

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
                    completion:(RequestBlock)completion;

/*
 *  退出登录
 *
 */
- (void)logoutCompletion:(void(^)(HDError *))completion;

//APNs
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

@end
