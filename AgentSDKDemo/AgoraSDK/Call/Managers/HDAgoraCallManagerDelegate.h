//
//  HDAgoraCallManagerDelegate.h
//  HelpDeskLite
//
//  Created by houli on 2022/1/6.
//  Copyright © 2022 hyphenate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDAgoraCallEnum.h"
#import "HDAgoraCallMember.h"
@class HDAgoraCallManager;
@protocol HDAgoraCallManagerDelegate <NSObject>

@optional

/*!
 *  \~chinese
 *  接收到视频请求
 *  @param nickName  昵称
 *
 *  \~english
 *  Receiving a Video request
 *
 */
- (void)onAgoraCallReceivedNickName:(NSString *)nickName;

/*!
 *  \~chinese
 *  成员进入会话
 *  @param member  成员
 *
 *  \~english
 *  Member enters session
 *
 */
- (void)onMemberJoin:(HDAgoraCallMember *)member;

/*!
 *  \~chinese
 *  成员离开会话
 *  @param member  成员
 *
 *  \~english
 *  Member exit session
 *
 */

- (void)onMemberExit:(HDAgoraCallMember *)member;

/*!
 *  \~chinese
 *  会话结束
 *  @param reason 原因
 *  @param desc 描述
 *
 *  \~english
 *  End of the session
 *
 */
- (void)onCallEndReason:(int)reason desc:(NSString *)desc;

/// 远端用户/主播加入回调  Occurs when the local user joins a specified channel.
/// @param agoraCallManager  agoraCallManager instance
/// @param uid User ID of the remote user sending the video stream.
/// @param elapsed Time elapsed (ms) from the local user calling the joinChannelByToken method until the SDK triggers this callback.
- (void)hd_rtcEngine:(HDAgoraCallManager *)agoraCallManager didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed;

/// 发生错误回调
/// @param agoraCallManager agoraCallManager instance
/// @param error error description
- (void)hd_rtcEngine:(HDAgoraCallManager *)agoraCallManager didOccurError:(HDError *)error;

/// 远端视频状态发生改变回调。
/// @param agoraCallManager agoraCallManager instance
/// @param uid 发生视频状态改变的远端用户 ID。
/// @param state 远端视频流状态。
/// @param reason 远端视频流状态改变的具体原因
/// @param elapsed 从本地用户调用 joinChannel 方法到发生本事件经历的时间，单位为 ms。
- (void)hd_rtcEngine:(HDAgoraCallManager *)agoraCallManager remoteVideoStateChangedOfUid:(NSUInteger)uid state:(HDAgoraVideoRemoteState)state reason:(HDAgoraVideoRemoteStateReason)reason elapsed:(NSInteger)elapsed;

/// 远端用户（通信场景）/主播（直播场景）离开当前频道回调
/// @param agoraCallManager agoraCallManager instance
/// @param uid 离线的用户 ID。
/// @param reason 离线原因
- (void)hd_rtcEngine:(HDAgoraCallManager *)agoraCallManager didOfflineOfUid:(NSUInteger)uid reason:(HDAgoraUserOfflineReason)reason;

/// 已显示本地视频首帧的回调
/// @param agoraCallManager agoraCallManager instance
/// @param size 本地渲染的视频尺寸（宽度和高度）
/// @param elapsed 从本地用户调用joinChannelByToken到发生此事件过去的时间（ms）。如果在joinChannelByToken前调用了startPreview，是从 startPreview 到发生此事件过去的时间。
- (void)hd_rtcEngine:(HDAgoraCallManager *)agoraCallManager  firstLocalVideoFrameWithSize:(CGSize)size elapsed:(NSInteger)elapsed;

/// 已完成远端视频首帧解码回调
/// @param agoraCallManager agoraCallManager instance
/// @param uid 远端用户 ID
/// @param size 视频流尺寸（宽度和高度）
/// @param elapsed 从本地用户调用 joinChannelByToken到发生此事件过去的时间（ms）。
- (void)hd_rtcEngine:(HDAgoraCallManager *)agoraCallManager firstRemoteVideoDecodedOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed;

/// 网络连接中断，且 SDK 无法在 10 秒内连接服务器回调
/// @param agoraCallManager agoraCallManager instance
- (void)hd_rtcEngineConnectionDidLost:(HDAgoraCallManager *)agoraCallManager;
@end

