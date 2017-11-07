//
//  HDClientDelegate.h
//  AgentSDK
//
//  Created by afanda on 4/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HDAutoLogoutReason) {
    HDAutoLogoutReasonDefaule = 322 , //401
    HDAutoLogoutReasonAgentDelete , //被删除
    HDUserAccountDidLoginFromOtherDevice, //其他平台登录
    HDUserAccountDidRemoveFromServer, //服务器强制下线
};

typedef NS_ENUM(NSUInteger, RolesChangeType) {
    RoleChangeTypeFromCommonToAdmin=21, //从普通客服转为管理员
    RoleChangeTypeFromAdminToCommon,    //从管理员转为普通客服
};

typedef NS_ENUM(NSUInteger, HDConnectionState) {
    HDConnectionConnected = 0,  /*  已连接 */
    HDConnectionDisconnected,   /*  未连接 */
};

@protocol HDClientDelegate <NSObject>

@optional
/*
 *  SDK连接服务器的状态变化时会接收到该回调
 *
 *  以下情况, 会调用该方法:
 *  1. 登录成功后, 手机无法上网时, 会调用该回调
 *  2. 登录成功后, 网络状态变化时, 会调用该回调
 */
- (void)connectionStateDidChange:(HDConnectionState)aConnectionState;


/**
 管理员是否允许客服自定义最大接待人数

 @param allow YES NO 分别表示允许、不允许
 */
- (void)allowAgentChangeMaxSessions:(BOOL)allow;


/**
  当前账号被迫下线

 @param reason 下线原因
 */
- (void)userAccountNeedRelogin:(HDAutoLogoutReason)reason;


#pragma mark - 调度


/*
 *  会话被管理员转接
 *  @param  serviceSessionId 被转接的会话ID
 */

- (void)conversationTransferedByAdminWithServiceSessionId:(NSString *)serviceSessionId;

/*
 * 会话被管理员关闭
 * @param  serviceSessionId 被关闭的会话ID
 */

- (void)conversationClosedByAdminWithServiceSessionId:(NSString *)serviceSessionId;

/*
 * 会话自动关闭 
 * @param  serviceSessionId 关闭的会话ID
 */
- (void)conversationAutoClosedWithServiceSessionId:(NSString *)serviceSessionId;


/**
 会话被确认转接【需要管理员开启“转接会话需要对方确认”】
 */
- (void)transferScheduleAccept:(NSString *)serviceSessionId;

/*
 * 会话最后一条消息变化
 * @param  sessionId 变化的sessionId
 */
- (void)conversationLastMessageChanged:(HDMessage *)message;
/*
 * 新会话
 * @param  sessionId 新会话sessionId
 */
- (void)newConversationWithSessionId:(NSString *)sessionId;


/*
 * 客服身份发生变化
 */
- (void)roleChange:(RolesChangeType)type;

/*
 * 待接入列表变化
 */
- (void)waitListChange;
/*
 * 客服列表发生变化
 */
- (void)agentUsersListChange;
/*
 * 通知中心有有变化
 */
- (void)notificationChange;


@end















