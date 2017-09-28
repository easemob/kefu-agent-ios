//
//  DXMessageManager.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/20.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "EaseMob.h"
#import <HyphenateLite/HyphenateLite.h>
#define MESSAGE_TYPE_NEWINSTANCELOGIN @"NewInstanceLogin"   // -- 新实例登录
#define MESSAGE_TYPE @"messageType"
#define MESSAGE_TYPE_NEWCHARMESSAGE @"NewChatMessage"       //新消息 -
#define MESSAGE_TYPE_SCHEDULE @"Schedule"                   //新的调度请求 -
#define MESSAGE_TYPE_AGENTUSER_LISTONCHANGE @"AgentUserListOnChange"//客服列表变化事件u-
#define MESSAGE_TYPE_AGENTUSER_StateChange @"AgentUserStateChange" //客服状态改变
#define MESSAGE_TYPE_AGENTUSERADD @"AgentUserAdd"//有新客服添加事件 -
#define MESSAGE_TYPE_AGENTUSERDELETE @"AgentUserDelete"//有客服被删除事件 -
#define MESSAGE_TYPE_WAITINGLISTCHANGE @"VisitUserWaitingListChange"//待接入数变化，发事件给客户端 - 
#define MESSAGE_TYPE_SESSIONCLOSE @"ServiceSessionClosed"//会话话自动关闭 -
#define MESSAGE_TYPE_TRANSFER_ACCEPT @"TransferScheduleAccept" //接受调度
#define MESSAGE_TYPE_TRANSFER_SCHEDULE @"TransferSchedule" //-调度
#define MESSAGE_TYPE_OPTION_CHANGE @"OptionChange" //客服是否可以自定义最大接待人数
#define MESSAGE_TYPE_ACTIVITY_CREATE @"ActivityCreate" //通知中心改变 aaa
#define MESSAGE_TYPE_AGENT_ROLE_CHANGE @"AgentRoleChange"//管理员列表变更 -
#define MESSAGE_TYPE_ALLOW_AGENT_MAX @"AllowAgentChangeMaxSessions"//
#define MESSAGE_TYPE_TICKET_CREATE @"TicketCreate" //收到留言
#define MESSAGE_TYPE_CONVERSATION_TRANSFERED @"ServiceSessionTransfered" //会话被管理员转接，会话列表更新
#define MESSAGE_TYPE_CONVERSATION_ADMINCLOSED @"ServiceSessionClosedByAdmin" //会话被admin关闭

#define MESSAGE_TYPE_OTHER_PLATFORMS_LOGIN @"AgentUserLoginFromMobileBeKickOff" //其他平台登录

//等待增加
#define MESSAGE_TYPE_ENQUIRY    @"Enquiry" // 访客给出评价
#define MESSAGE_TYPE_SHORTCUTMESSAGCHANGE @"ShortcutMessageChange" // 快捷回复变更
#define MESSAGE_TYPE_TRANSFERSCHEDULETIMEOUT   @"TransferScheduleTimeout" //A转给B。超时
#define MESSAGE_TYPE_TRANSFERSCHEDULEDENY @"TransferScheduleDeny" // A转给B。被拒绝
#define MESSAGE_TYPE_SERVICESESSIONATTRIBUTESCHANGE @"ServiceSessionAttributesChange" // IP 等信息改变
#define MESSAGE_TYPE_ACTIVITYCREATEEVENT @"ActivityCreateEvent" //aaa
#define MESSAGE_TYPE_SERVICESESSIONSUMMARYCREATE @"ServiceSessionSummaryCreate" // 标签
#define MESSAGE_TYPE_SERVICESESSIONSUMMARYCHANGE @"ServiceSessionSummaryChange" //
#define MESSAGE_TYPE_SERVICESESSIONSUMMARYDELETE @"ServiceSessionSummaryDelete" //
#define MESSAGE_TYPE_PRO @"ProcessingListChange" //暂时没用


// 连接状态
typedef enum DXMessageManagerState
{
    DX_DISCONNECTED,
    DX_CONNECTED,
} DXMessageManagerState;

@interface DXMessageManager : NSObject <EMChatManagerDelegate>

+ (instancetype)shareManager;

- (BOOL)currentState;

- (void)setCurSessionId:(NSString*)curSessionId;

- (NSString*)curSessionId;

- (void)registerEaseMobNotification;

@end
