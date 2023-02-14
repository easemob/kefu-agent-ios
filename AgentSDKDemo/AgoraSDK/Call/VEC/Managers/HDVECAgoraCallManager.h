//
//  HDAgoraCallManager.h
//  HelpDeskLite
//
//  Created by houli on 2022/1/6.
//  Copyright © 2022 hyphenate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import "HDVECAgoraCallOptions.h"
#import "HDVECAgoraCallManagerDelegate.h"
#import "HDVECTicketModel.h"
#import "HDVECRingingCallModel.h"

NS_ASSUME_NONNULL_BEGIN
static NSString * _Nonnull kVECUserDefaultState = @"VEC_KEY_BXL_DEFAULT_STATE_agent"; // 接收屏幕共享(开始/结束 状态)监听的Key

static NSString * _Nonnull kVECAppGroup = @"group.com.easemob.enterprise.demo.kefuapp";
static void *VECKVOContext = &VECKVOContext;
@interface HDVECAgoraCallManager : NSObject
@property (strong, nonatomic) AgoraRtcEngineKit *agoraKit;
@property (strong, nonatomic) AgoraScreenCaptureParameters2 * screenCaptureParams;
@property (nonatomic, weak) id <HDVECAgoraCallManagerDelegate> roomDelegate;
@property (nonatomic, strong) HDKeyCenter *keyCenter;
@property (nonatomic, strong) NSString *conversationId;
@property (nonatomic, strong) NSUserDefaults *userDefaults;

@property (nonatomic, strong) HDMessage * message;
@property (nonatomic, strong) NSString *sessionId;
@property (nonatomic, strong) NSArray *recordDetails;
@property (nonatomic, strong) UserModel *chatter;

@property (nonatomic, assign) BOOL isSender;
@property (nonatomic, assign) BOOL isCurrentCalling; // 当前是不是 正在呼叫
@property (nonatomic, assign) HDAgentServiceType currentAgentServiceType; // 当前坐席类型
@property (nonatomic, strong) HDVECRingingCallModel * ringingCallModel;

+ (instancetype _Nullable )shareInstance;
/// 解析获取的通行证接口的数据
/// @param dic  获取通行证接口返回的源数据
- (BOOL)vec_setAgoraTicketModel:(NSDictionary *)dic;
//获取坐席加入房间的数据
- (HDVECTicketModel *)vec_getAgentTicketCallOptions;
//获取访客加入房间的数据
- (HDVECTicketModel *)vec_getVisitorTicketCallOptions;
//获取屏幕分享加入房间的数据
- (HDVECTicketModel *)vec_getShareScreenTicketCallOptions;
/*!
 *  \~chinese
 *   VEC-  设置坐席状态
 */
- (void)vec_SetVECAgentStatus:(HDAgentServiceType )type completion:(void (^_Nullable)(id responseObject, HDError * error))completion;

/*!
 *  \~chinese
 *   VEC-  获取坐席状态
 */
- (void)vec_GetVECAgentStatusCompletion:(void (^_Nullable)(id responseObject, HDError * error))completion;

/*!
 *  \~chinese
 *   初始化 agora init
 *
 */
- (void)vec_createTicketDidReceiveAgoraInit;


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
- (void)setCallOptions:(HDVECAgoraCallOptions *_Nullable)aOptions;

/*!
 *  \~chinese
 *  获取通话状态  YES 通话中。NO 未通话
 */
- (BOOL)getCallState;
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
- (HDVECAgoraCallOptions *_Nullable)getCallOptions;

/*!
 *  \~chinese
 *   接受视频会话
 *
 *   @param nickname 传递自己的昵称到对方
 *   @param completion 完成回调
 *
 */
- (void)vec_acceptCallWithNickname:(NSString *)nickname completion:(void (^_Nullable)(id, HDError *))completion;

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
 *  开启/关闭视频模块
 *
 *  \~english
 *  Resume video data transmission
 */
- (void)enableLocalVideo:(BOOL )enabled;

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
 *  离开房间
 */
- (void)leaveChannel;
/*!
 *  \~chinese
 *  加入房间
 */
- (void)joinChannel;
/*!
 *  \~chinese
 *  结束视频会话。

 *  \~english
 *  Ending a Video Session
 */
- (void)endCall;

/*!
 *  \~chinese
 *  结束视频会话。 vec 独立访客端

 *  \~english
 *  Ending a Video Session
 */
- (void)endVecCall;
/*!
 *  \~chinese
 *  结束视频会话  通话中结束。 vec 独立访客端

 *  \~english
 *  Ending a Video Session
 */
- (void)closeVecCall;

/*!
 *  \~chinese
 *  拒绝视频会话。

 *  \~english
 *  Ending a Video Session
 */
- (void)refusedCall;
/*!
 *  \~chinese
 *  拒绝视频会话。 vec独立访客端

 *  \~english
 *  Ending a Video Session
 */
- (void)refusedVecCall;
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
- (void)initSettingWithCompletion:(void(^)(id  responseObject, HDError *error))aCompletion ;

/// 保存屏幕共享需要的数据
- (void)hd_saveShareDeskData:(HDKeyCenter*)keyCenter;

/// 获取会话全部视频通话详情
- (void)getAllVideoDetailsSession:(NSString *)sessionId completion:(void(^)(id responseObject,HDError *error))aCompletion;
/// 构造给访客端加入房间的参数
- (NSDictionary *)vec_getSendVisitorTicketWithVisitorNickname:(NSString *)nickName withVisitorTrueName:(NSString *)trueName;
//发送 cmd 消息 把访客端需要加入房间的数据带过去
- (void)vec_sendCmdMessage:(NSDictionary *)msgtypeDic withSessionId:(NSString *)sessionId withToUser:(NSString *)toUser completion:(void (^)(HDMessage * message, HDError *error))aCompletionBlock;
/// 获取对端访客视频截图
- (void)getVisitorScreenshotCompletion:(void(^)(NSString * url,HDError *error))aCompletion;

@end

NS_ASSUME_NONNULL_END
