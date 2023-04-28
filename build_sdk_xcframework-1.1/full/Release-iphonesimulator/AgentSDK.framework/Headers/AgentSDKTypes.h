//
//  AgentSDKTypes.h
//  AgentSDK
//
//  Created by 杜洁鹏 on 2018/5/2.
//  Copyright © 2018年 环信. All rights reserved.
//

#ifndef AgentSDKTypes_h
#define AgentSDKTypes_h

typedef NS_ENUM(NSUInteger, HDSatisfationStatus) {
    HDSatisfationStatusNone = 0, //尚未发送
    HDSatisfationStatusInvited, //已经发送,用户尚未评价
    HDSatisfationStatusOver //用户已经评价
};

typedef NS_ENUM(NSUInteger, HDDownloadStatus) {
    HDDownloadStatusDownloading = 0, //正在下载
    HDDownloadStatusSucceed,    //下载成功
    HDDownloadStatusFailed, //下载失败
    HDDownloadStatusPending //准备下载
};

typedef NS_ENUM(NSUInteger, HDMessageDeliveryState) {
    HDMessageDeliveryState_Pending = 0,
    HDMessageDeliveryState_Delivering,
    HDMessageDeliveryState_Delivered,
    HDMessageDeliveryState_Failure
};

typedef NS_ENUM(NSUInteger, HDChatType) {
    HDChatTypeChat = 0, //单聊
    HDChatTypeCustomer //客服同事聊天
};

typedef NS_ENUM(NSUInteger, HDSessionTag) {
    HDSessionTagAll = 0,
    HDSessionTagWithTag,
    HDSessionTagNoTag
};

typedef NS_ENUM(NSUInteger, HDColumnType) {
    HDColumnTypeSingleText = 1, //单行文本
    HDColumnTypeMultiText, //多行文本
    HDColumnTypeMultiSelected,//多选
    HDColumnTypeNumber, //数字
    HDColumnTypeDate //日期
};

typedef NS_ENUM(NSUInteger, HDNoticeStatus) {
    HDNoticeStatusRead = 66,    //已读
    HDNoticeStatusUnread     //未读
};

typedef NS_ENUM(NSUInteger, HDNoticeType) {
    HDNoticeTypeAll = 88,          //所有消息
    HDNoticeTypeAgent,     //管理员消息
    HDNoticeTypeSystem       //系统消息
};

typedef NS_ENUM(NSUInteger, HDOnlineStatus) {
    HDOnlineStatusOnline = 0,   //在线
    HDOnlineStatusBusy,     //忙碌
    HDOnlineStatusLeave,    //离开
    HDOnlineStatusHidden    //隐身
};

typedef NS_ENUM(NSUInteger, HDConversationType) {
    HDConversationAccessed = 1,     //已经接入
    HDConversationWaitQueues,       //待接入
    HDConversationHistory          //历史会话
};

typedef NS_ENUM(NSUInteger, HDAutoLogoutReason) {
    HDAutoLogoutReasonDefaule = 322 , //401
    HDAutoLogoutReasonAgentDelete , //被删除
    HDUserAccountDidLoginFromOtherDevice, //其他平台登录
    HDUserAccountDidRemoveFromServer, //服务器强制下线
    HDUserAccountDidForbidByServer
};

typedef NS_ENUM(NSUInteger, RolesChangeType) {
    RoleChangeTypeFromCommonToAdmin = 21, //从普通客服转为管理员
    RoleChangeTypeFromAdminToCommon    //从管理员转为普通客服
};

typedef NS_ENUM(NSUInteger, HDConnectionState) {
    HDConnectionConnected = 0,  /*  已连接 */
    HDConnectionDisconnected   /*  未连接 */
};


typedef NS_ENUM(NSUInteger, HDExtMsgType) {
    HDExtMsgTypeGeneral = 0, //正常消息
    HDExtMsgTypeMenu , //菜单消息
    HDExtMsgTypeTrack, //轨迹消息
    HDExtMsgTypeOrder, //订单消息
    HDExtMsgTypeForm,  //表单消息
    HDExtMsgTypeArticle, //图文消息
    HDExtMsgTypeHtml, //html消息
    HDExtMsgTypeLiveStreamInvitation, //访客邀请坐席视频
    HDExtMsgTypeVisitorCancelInvitation, //访客取消坐席视频邀请
    HDExtMsgTypeVisitorRejectInvitation, //访客拒绝坐席视频邀请
    HDExtMsgTypevideoPlayback // 视频通话挂断
};

typedef NS_ENUM(NSUInteger, HDAgentLoginStatus) {
    HDAgentLoginStatusOnline = 0, //空闲
    HDAgentLoginStatusBusy , //忙碌
    HDAgentLoginStatusLeave, //离开
    HDAgentLoginStatusHidden, //隐身
    HDAgentLoginStatusOffline //离线
};
typedef NS_ENUM(NSUInteger, HDVECAgentLoginStatus) {
    HDVECAgentLoginStatusIdle = 0, //空闲
    HDVECAgentLoginStatusBusy , //忙碌
    HDVECAgentLoginStatusRest, //小休
    HDVECAgentLoginStatusOffline,  //离线
    HDVECAgentLoginStatusRINGING,  //振铃中
    HDVECAgentLoginStatusPROCESSING //通话中
};
typedef NS_ENUM(NSUInteger, HDAgentServiceType) {
    HDAgentServiceType_VEC= 0, // 当前坐席是视频客服
    HDAgentServiceType_Online , //当前坐席是在线客服
    HDAgentServiceType_General //当前坐席是在线客服+视频客服
    
};

typedef NS_ENUM(NSUInteger, HDObjectType) {
    HDObjectType_AgentType,
    HDObjectType_TeamsType
};

typedef NS_ENUM(NSUInteger, HDMessageBodyType) {
    HDMessageBodyTypeText = 0,   //文字消息
    HDMessageBodyTypeImage,      //图片消息
    HDMessageBodyTypeVoice,      //语音消息
    HDMessageBodyTypeFile,       //文件消息
    HDMessageBodyTypeVideo,      //视频消息
    HDMessageBodyTypeCommand,     //命令消息
    HDMessageBodyTypeLocation,   //位置消息
    HDMessageBodyTypeImageText,  //轨迹
    HDMessageBodyTypePlayBack  //视频通话记录
};

typedef NS_ENUM(NSUInteger, HDConversationModelType) {
    HDConversationModelUserType = 0,
    HDConversationModelCustomerType
};

typedef NS_ENUM(NSUInteger, HChannelType) {
    HChannelType_All = 0,
    HChannelType_Web,
    HChannelType_App,
    HChannelType_WeiBo,
    HChannelType_WeiChat
};
#endif /* AgentSDKTypes_h */
