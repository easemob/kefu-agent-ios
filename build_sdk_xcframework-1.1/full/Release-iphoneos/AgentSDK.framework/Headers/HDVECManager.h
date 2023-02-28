//
//  HDVECCallManager.h
//  AgentSDK
//
//  Created by easemob on 2023/2/7.
//  Copyright © 2023 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDVECManager : NSObject
@property (nonatomic, strong) NSString *callId;
@property (nonatomic, strong) NSString *channel;

@property (nonatomic, strong) NSString *agentCallId;
@property (nonatomic, strong) NSString *agentChannel;
@property (nonatomic, strong) NSString *sesstionId;

@property (nonatomic, strong) NSString *toUser;
@property (nonatomic, assign) BOOL isCalling;

+ (instancetype)sharedInstance;

#pragma mark --------------------------vec 接口相关 -------------------------------

/// v1.2-视频坐席状态  设置空闲状态才能进行视频
/// @param status 状态
- (void)vec_updateAgentStatus:(HDVECAgentLoginStatus )status
                              completion:(void (^)(id responseObject, HDError *error))completion;
/// v1.2-获取坐席视频状态接口
- (void)vec_getAgentStatusCompletion:(void (^)(id responseObject, HDError *error))completion;

/// 获取视频通话ticket(点击振铃接听按钮调用)
/// @param agentId  坐席id
/// @param rtcSessionId  会话id
- (void)vec_getAgoraTicketWithRtcSessionId:(NSString *)rtcSessionId withAgentId:(NSString *)agentId completion:(void(^)(id responseObject,HDError *error))aCompletion;

/// 获取视频通话ticket(点击待接入接听按钮调用)
/// @param agentId  坐席id
/// @param rtcSessionId  会话id
- (void)vec_getAgoraWaitTicketWithRtcSessionId:(NSString *)rtcSessionId withAgentId:(NSString *)agentId completion:(void(^)(id responseObject,HDError *error))aCompletion;

/// 开始录制
/// @param agentId  坐席id
/// @param rtcSessionId  会话id
- (void)vec_startAgoraRtcRecodWithRtcSessionId:(NSString *)rtcSessionId withAgentId:(NSString *)agentId completion:(void(^)(id responseObject,HDError *error))aCompletion;

/// 停止录制
/// @param agentId  坐席id
/// @param rtcSessionId  会话id
- (void)vec_stoptAgoraRtcRecodWithRtcSessionId:(NSString *)rtcSessionId withAgentId:(NSString *)agentId completion:(void(^)(id responseObject,HDError *error))aCompletion;

/// 坐席振铃拒接
/// @param agentId  坐席id
/// @param rtcSessionId  会话id
- (void)vec_agentRejectWithRtcSessionId:(NSString *)rtcSessionId withAgentId:(NSString *)agentId completion:(void(^)(id responseObject,HDError *error))aCompletion;

/// 坐席拒绝接起视频通话
/// @param rtcSessionId  会话id
/// @param visitorId    访客id
- (void)vec_agentRejectInvitationWithRtcSessionId:(NSString *)rtcSessionId withToVisitorId:(NSString *)visitorId completion:(void(^)(id responseObject,HDError *error))aCompletion;

/*
 * 坐席给访客发送消息
 * 发送消息给会话【包括文字、图片、语音等消息】
 */
- (void)vec_asyncSendMessageWithMessageModel:(HDMessage *)MessageModel
                              completion:(void(^)(HDMessage *message,HDError *error))completion;
/**
 上传截图
 @param imageData 图片data
 @param completion 完成回调
 */
- (void)vec_asyncUploadScreenshotImageWithFile:(NSData*)imageData
                       completion:(void (^)(NSString *url, HDError *error))completion;


/**
   获取视频记录
 Integer pageNum 页码(默认0)
 Integer pageSize 页大小（默认10）
 Integer tenantId 租户ID
 String agentUserId 客服ID
 String visitorUserId 访客ID
 Date createDateFrom 通话创建时间（开始范围条件）
 Date createDateTo 通话创建时间（结束范围条件）
 Date startDateFrom 首次通话接起时间（开始范围条件）
 Date startDateTo 首次通话接起时间（结束范围条件）
 Date stopDateFrom 结束时间（开始范围条件）
 Date stopDateTo 通话结束时间（结束范围条件）
 List<TechChannel> techChannels 关联（TechChannel对象参数，String techChannelType 关联类型，String techChannelId 关联ID）
 List<String> originType 渠道类型
 boolean isAgent 是否使用客服角色进行查询（坐席/管理员）
 String sortField  排序字段（默认createDatetime）
 String sortOrder 正序倒序标识（默认desc）
 String rtcSessionId 视频ID，如果指定了这个，别的条件就不生效了
 List<Integer> queueIds 技能组Ids
 List<String> hangUpReason 挂断类型
 List<String> hangUpUserType 挂断方
 String customerName 客户名
 String visitorName 访客名
 List<String> state 通话状态（结束为"Terminal","Abort"）
 @param data   请求参数体  是一个json串 里边设置筛选条件参数 参数请参考以上字段
 */
- (void)vec_getRtcSessionhistoryParameteData:(NSDictionary*)data
                       completion:(void (^)(id responseObject, HDError *error))completion;


/*
 * 获取视频详情
 */

- (void)vec_getCallVideoDetailWithRtcSessionId:(NSString *)rtcSessionId Completion:(void(^)(id responseObject, HDError *error))completion;

//待接入 相关接口
/*
 * 待接入数量 这个接口需要需要轮训获取排队数量
 */

- (void)vec_getSessionsCallWaitWithAgentId:(NSString *)agentId Completion:(void(^)(id responseObject, HDError *error))completion;
/*
 * 待接入列表 这个接口需要需要轮训获取排队列表
 {
   "page": 0,
   "size": 20,
   "mode": "agent", //  如果要获取管理员下所有的列表 传admin
   "beginDate": "2022-05-05T00:00:00",
   "endDate": "2022-05-06T00:00:00",
   "techChannelId": 27230,
   "originType": "app",
   "visitorUserId": "id"
 }'
 */
- (void)vec_postSessionsCallWaitListParameteData:(NSDictionary*)data Completion:(void(^)(id responseObject, HDError *error))completion;

/*
 * 待接入 获取接听 音视频ticket 通行证
 */
- (void)vec_getSessionsCallWaitTicketWithAgentId:(NSString *)agentId withRtcSessionId:(NSString *)rtcSessionId Completion:(void(^)(id responseObject, HDError *error))completion;

/*
 * 拒接待接入通话
 */
- (void)vec_postSessionsCallWaitRejectWithAgentId:(NSString *)agentId withRtcSessionId:(NSString *)rtcSessionId Completion:(void(^)(id responseObject, HDError *error))completion;



@end

NS_ASSUME_NONNULL_END
