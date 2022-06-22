//
//  HDAgoraCallManager.h
//  HelpDeskLite
//
//  Created by houli on 2022/1/6.
//  Copyright © 2022 hyphenate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import "HDAgoraCallOptions.h"
#import "HDAgoraCallManagerDelegate.h"
@class HDAgoraCallViewController;
NS_ASSUME_NONNULL_BEGIN
@interface HDAgoraCallManager : NSObject
@property (nonatomic, strong) HDAgoraCallViewController *hdVC;
@property (nonatomic, strong) HDMessage * message;
@property (nonatomic, strong) NSString *sessionId;
@property (nonatomic, strong) UserModel *chatter;

+ (instancetype _Nullable )shareInstance;

/*!
 *  \~chinese
 *   初始化 agora init 
 *
 */
- (void)createTicketDidReceiveAgoraInit;

/*!
 *  \~chinese
 *  坐席主动 发起视频邀请
 *  @param sessionId   sessionId
 *  @param toUser   agentId
 *  @param text   文本内容
 *
 */
- (HDMessage *)creteVideoInviteMessageWithSessionId:(NSString *)sessionId
                                                 to:(NSString *)toUser
                                           WithText:(NSString *)text;
/*!
 *  \~chinese
 *  坐席挂断视频邀请
 *  @param sessionId   sessionId
 *  @param toUser   agentId
 *  @param text   文本内容
 *
 */
- (HDMessage *)hangUpVideoInviteMessageWithSessionId:(NSString *)sessionId
                                                 to:(NSString *)toUser
                                           WithText:(NSString *)text;
/*!
 *  \~chinese
 *  获取坐席创建房间的设置项
 *
 *  @result 设置项
 *
 *  \~english
 *  Get setting options
 *
 *  @result Setting options
 */
- (NSDictionary * )getAgentCallOptions;
/*!
 *  \~chinese
 *  获取访客创建房间的设置项
 *
 *  @result 设置项
 *
 *  \~english
 *  Get setting options
 *
 *  @result Setting options
 */
- (NSDictionary * )getVisitorCallOptions;
#pragma mark - Options
/*!
 *  \~chinese
 *  设置设置项
 *
 *  @param aOptions  设置项
 *
 *  \~english
 *  Set setting options
 */
- (void)setCallOptions:(HDAgoraCallOptions *_Nullable)aOptions;

/*!
 *  \~chinese
 *  获取设置项
 *
 *  @result 设置项
 *
 *  \~english
 *  Get setting options
 *
 *  @result Setting options
 */
- (HDAgoraCallOptions *_Nullable)getCallOptions;

/// 获取会话全部视频通话详情
- (void)getAllVideoDetailsSession:(NSString *)sessionId completion:(void(^)(id responseObject,HDError *error))aCompletion;
/*!
 *  \~chinese
 *    加入 视频会话
 *
 *   @param nickname 传递自己的昵称到对方
 *   @param completion 完成回调
 *
 */
- (void)hd_joinCallWithNickname:(NSString *)nickname completion:(void (^_Nullable)(id, HDError *))completion;

/*!
 *  \~chinese
 *  获取已经加入的members
 *
 *  @result 已经加入的成员
 *
 *  \~english
 *  Get has joined members
 *
 *  @result has joined members
 */
- (NSArray *_Nullable)hasJoinedMembers;
/*!
 *  \~chinese
 *   切换摄像头
 *
 *  \~english
 *  Switching cameras
 */

- (void)switchCamera;
/*!
 *  \~chinese
 *  暂停语音数据传输
 *
 *  \~english
 *  Suspend voice data transmission
 */
- (void)pauseVoice;

/*!
 *  \~chinese
 *  恢复语音数据传输
 *
 *
 *  \~english
 *  Resume voice data transmission
 *
 */
- (void)resumeVoice;

/*!
 *  \~chinese
 *  暂停视频图像数据传输
 *
 *  \~english
 * Suspend video data transmission
 */
- (void)pauseVideo;

/*!
 *  \~chinese
 *  恢复视频图像数据传输
 *
 *  \~english
 *  Resume video data transmission
 */
- (void)resumeVideo;
/*!
 *  \~chinese
 *  开启/关闭扬声器播放。

 *  \~english
 *  Enables/Disables the audio route to the speakerphone
 */
- (void)setEnableSpeakerphone:(BOOL)enableSpeaker;

/*!
 *  \~chinese
 *  开启/关闭 虚拟背景。

 *  \~english
 *  Enables/Disables enableVirtualBackground
 */
- (void)setEnableVirtualBackground:(BOOL)enable;

/*!
 *  \~chinese
 *  结束视频会话。

 *  \~english
 *  Ending a Video Session
 */
- (void)endCall;

/*!
 *  \~chinese
 *  销毁对象
 *  一个 App ID 只能用于创建一个 AgoraRtcEngineKit。如需更换 App ID，必须先调用 destroy 销毁当前 AgoraRtcEngineKit，并在 destroy 成功返回后，再调用 sharedEngineWithAppId 重新创建 AgoraRtcEngineKit。

 *  \~english
 *  destroy
 */
- (void)destroy;

/// 初始化本地视图。
/// @param localView 设置本地视频显示属性。
- (void)setupLocalVideoView:(UIView *)localView;
/// 初始化远端视图。
/// @param remoteView  远端试图
/// @param uid  远端的uid
- (void)setupRemoteVideoView:(UIView *)remoteView withRemoteUid:(NSInteger )uid;
#pragma mark - Delegate
/*!
 *  \~chinese
 *  添加回调代理
 *
 *  @param aDelegate  要添加的代理
 *  @param aQueue     执行代理方法的队列
 *
 *  \~english
 *  Add delegate
 *
 */
- (void)addDelegate:(id<HDAgoraCallManagerDelegate>_Nullable)aDelegate
      delegateQueue:(dispatch_queue_t _Nullable )aQueue;

/*!
 *  \~chinese
 *  移除回调代理
 *
 *  @param aDelegate  要移除的代理
 *
 *  \~english
 *  Remove delegate
 *
 */
- (void)removeDelegate:(id<HDAgoraCallManagerDelegate>_Nullable)aDelegate;

/*!
 *  \~chinese
 *  开始屏幕录制
 *
 *  @param sampleBuffer  视频流
 *
 *  \~english
 *  Start screen recording
 *
 */
- (void)startBroadcast;

/*!
 *  \~chinese
 *  发送视频流
 *  @param sampleBuffer  视频流
 *
 *  \~english
 *  Send a video stream
 *
 */
- (void)sendVideoBuffer:(CMSampleBufferRef _Nullable )sampleBuffer;

/*!
 *  \~chinese
 *  停止录屏
 *
 *  \~english
 *  stop a video stream
 *
 */
- (void)stopBroadcast;
/*!
 *  \~chinese
 *   获取录屏状态
 *
 */
- (BOOL)getBroadcastState;

/*!
 *  \~chinese
 *  获取屏幕分享实例
 *
 *  \~english
 *  Get the screen sharing instance
 *
 */
- (AgoraRtcEngineKit * _Nullable )getBroadcastRtcEngine;

/*!
 *  \~chinese
 *  获取屏幕分享必要通信参数 主要用于判断进程通信是否 正常
 *
 *  \~english
 *  Obtaining screen sharing communication parameters is used to determine whether processes are communicating properly
 *
 */
- ( NSArray* _Nullable )getBroadcastParameter;

@end

NS_ASSUME_NONNULL_END
