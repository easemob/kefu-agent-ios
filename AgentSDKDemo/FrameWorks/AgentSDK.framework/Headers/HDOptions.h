//
//  HDOptions.h
//  AgentSDK
//
//  Created by afanda on 4/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDOptions : NSObject

/*
 *  控制台是否输出log, 默认为NO
 */
@property (nonatomic, assign) BOOL enableConsoleLog;

/*
 * 推送证书的名称
 */
@property (nonatomic, copy) NSString *apnsCertName;


/**
 是否显示访客输入状态
 */
@property(nonatomic,assign) BOOL showVisitorInputState;

/***************SDK 私有部署属性*************/
/**
 * 客服服务器地址
 */
@property (nonatomic, copy) NSString *kefuRestAddress;
/*!
 *  \~chinese
 *  是否允许使用DNS, 默认为YES
 *
 *  只能在[HChatClient initializeSDKWithOptions:]中设置，不能在程序运行过程中动态修改。
 *
 *  \~english
 *  Whether to allow using DNS, default is YES
 *
 *  Can only be set when initializing the SDK [HChatClient initializeSDKWithOptions:], cannot be altered in runtime
 */
@property (nonatomic, assign) BOOL enableDnsConfig;
 
/*!
 *  \~chinese
 *  IM服务器端口
 *
 *  enableDnsConfig为NO时有效。只能在[HChatClient initializeSDKWithOptions:]中设置，不能在程序运行过程中动态修改
 *
 *  \~english
 *  IM server port
 *
 *  chatPort is Only effective when isDNSEnabled is NO.
 *  Can only be set when initializing the SDK with [HChatClient initializeSDKWithOptions:], cannot be altered in runtime
 */
@property (nonatomic, assign) int chatPort;
    
/*!
 *  \~chinese
 *  IM服务器地址
 *
 *  enableDnsConfig为NO时生效。只能在[HChatClient initializeSDKWithOptions:]中设置，不能在程序运行过程中动态修改
 *
 *  \~english
 *  IM server
 *
 *  chatServer is Only effective when isDNSEnabled is NO. Can only be set when initializing the SDK with [HChatClient initializeSDKWithOptions:], cannot be altered in runtime
 */
@property (nonatomic, copy) NSString *chatServer;
    
/*!
 *  \~chinese
 *  REST服务器地址
 *
 *  enableDnsConfig为NO时生效。只能在[HChatClient initializeSDKWithOptions:]中设置，不能在程序运行过程中动态修改
 *
 *  \~english
 *  REST server
 *
 *  restServer Only effective when isDNSEnabled is NO. Can only be set when initializing the SDK with [HChatClient initializeSDKWithOptions:], cannot be altered in runtime
 */
@property (nonatomic, copy) NSString *restServer;
@end
