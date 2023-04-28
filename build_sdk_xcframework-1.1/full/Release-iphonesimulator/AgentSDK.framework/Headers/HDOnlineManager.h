//
//  HLCallManager.h
//  AgentSDK
//
//  Created by houli on 2022/2/15.
//  Copyright © 2022 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDOnlineManager : NSObject
@property (nonatomic, strong) NSString *callId;
@property (nonatomic, strong) NSString *channel;

@property (nonatomic, strong) NSString *agentCallId;
@property (nonatomic, strong) NSString *agentChannel;
@property (nonatomic, strong) NSString *sesstionId;

@property (nonatomic, strong) NSString *toUser;
@property (nonatomic, assign) BOOL isCalling;


+ (instancetype)sharedInstance;

- (void)setAgoraTicketDic:(NSDictionary *)dic;

- (void)setVideoPlaybackDic:(NSDictionary *)dic;

- (NSDictionary *)getAgentTicketCallOptions;
- (NSDictionary *)getVisitorTicketCallOptions;
- (NSArray *)getVideoPlayBackVideoDetails;

- (NSArray *)getVideoPlayBackVideoDetailsAll;


// 坐席主动邀请访客发起视频
- (HDMessage *)kf_CreatAgentSendMessageLiveStreamInvitationSessionId:(NSString *)sessionId withToUser:(NSString *)toUser;

// 视频结束发消息
- (HDMessage *)kf_sendMessageVideoPlaybackSessionId:(NSString *)sessionId withToUser:(NSString *)toUser withVisitorName:(NSString *)visitorName withVideoStartTime:(NSString *)videoStartTime withVideoEndTime:(NSString *)videoEndTime withCallId:(NSString *)callid;

//封装发送给访客加入参数的方法
- (NSDictionary *)getSendVisitorTicketWithVisitorNickname:(NSString *)nickName withVisitorTrueName:(NSString *)trueName;

//发送 cmd 消息
- (void)kf_sendCmdMessage:(NSDictionary *)msgtypeDic withSessionId:(NSString *)sessionId withToUser:(NSString *)toUser completion:(void (^)(HDMessage * message, HDError *error))aCompletionBlock;


/// 获取会话全部视频通话详情
- (void)getAllVideoDetailsSession:(NSString *)sessionId completion:(void(^)(id responseObject,HDError *error))aCompletion;

/// 获取视频通行证信息
/// @param callId  呼叫id
/// @param sessionId  会话id
- (void)getAgoraTicketWithCallId:(NSString *)callId withSessionId:(NSString *)sessionId completion:(void(^)(id responseObject,HDError *error))aCompletion;

/// 开始录制视频
/// @param callId  呼叫id
/// @param sessionId  会话id
- (void)startAgoraRtcRecodCallId:(NSString *)callId withSessionId:(NSString *)sessionId;

/// 结束录制
/// @param callId  呼叫id
/// @param sessionId  会话id
- (void)stopAgoraRtcRecodCallId:(NSString *)callId withSessionId:(NSString *)sessionId completion:(void(^)(id responseObject,HDError *error))aCompletion;;

/// 邀请坐席同事
/// @param callId  呼叫id
/// @param sessionId  会话id
/// @param remoteAgentId  被呼叫坐席id
- (void)agentInviteCallId:(NSString *)callId withSessionId:(NSString *)sessionId withRemoteAgentId:(NSString *)remoteAgentId;

/// 获取当前通话详情
/// @param callId  呼叫id
/// @param sessionId  会话id
/// @param remoteAgentId  被呼叫坐席id
- (void)getCurrentCallDetailsCallId:(NSString *)callId completion:(void(^)(id responseObject,HDError *error))aCompletion;

/// 获取坐席未接视频通话
- (void)getCurrentringingCallsCompletion:(void(^)(id responseObject,HDError *error))aCompletion;

/**
 上传截图
 @param imageData 图片data
 @param completion 完成回调
 */
- (void)asyncUploadScreenshotImageWithFile:(NSData*)imageData
                       completion:(void (^)(NSString *url, HDError *error))completion;

@end

NS_ASSUME_NONNULL_END
