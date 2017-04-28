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

/*
 *  聊天模块
 */
@property (nonatomic, strong, readonly) HDChatManager *chatManager;

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


@end
