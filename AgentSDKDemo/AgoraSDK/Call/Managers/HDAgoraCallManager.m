//
//  HDAgoraCallManager.m
//  HelpDeskLite
//
//  Created by houli on 2022/1/6.
//  Copyright © 2022 hyphenate. All rights reserved.
//

#import "HDAgoraCallManager.h"
#import <ReplayKit/ReplayKit.h>
#import <CoreMedia/CoreMedia.h>
#import "ConvertToCommonEmoticonsHelper.h"
#import "HDKeyCenter.h"
#import "HDSSKeychain.h"
#import "HDAgoraTicketModel.h"
#define kToken @"00674855635d3a64920b0c7ee3684f68a9fIACDuk6y5dEmj8KroRHLukc9ONx1Fqw7Ve+Y3ADi6jAvqRo6pkUAAAAAEACdNB6V1moMYgEAAQDVagxi";
#define kAPPid  @"74855635d3a64920b0c7ee3684f68a9f";
#define kChannelName @"huanxin"

#define kForService @"com.easemob.enterprise.demo.customer.ScreenShare"
#define kSaveAgoraToken @"call_agoraToken"
#define kSaveAgoraChannel @"call_agoraChannel"
#define kSaveAgoraAppID @"call_agoraAppid"
#define kSaveAgoraShareUID @"call_agoraShareUID"

// 存放屏幕分享的状态
#define kSaveScreenShareState @"Easemob_ScreenShareState"
static NSInteger audioSampleRate = 48000;
static NSInteger audioChannels = 2;
static uint32_t SCREEN_SHARE_UID_MIN  = 501;
static uint32_t SCREEN_SHARE_UID_MAX  = 1000;

@interface HDAgoraCallManager () <AgoraRtcEngineDelegate,HDChatManagerDelegate>
{
    HDGCDMulticastDelegate<HDAgoraCallManagerDelegate> *_delegates;
    HDAgoraCallOptions *_options;
    AgoraRtcVideoCanvas *_canvas;
    NSString *_nickName;
    NSDictionary *_ext;
    NSString *_ticket;
    HDKeyCenter *_keyCenter;
    NSString *_conversationId;
    
}

@property (nonatomic, strong) NSMutableArray *members;
@property (strong, nonatomic) AgoraRtcEngineKit *agoraKit;
@property (nonatomic, strong) AgoraRtcEngineKit *agoraKitScreenShare;
@property (nonatomic, copy) void (^Completion)(id, HDError *)  ;
@property (nonatomic, strong) HDConversation * conversationModel;


@end
@implementation HDAgoraCallManager
{
    BOOL _onCalling; //正在通话
    NSMutableDictionary *_cacheStreams; //没有点击接受的时候缓存的stream
    NSMutableArray *_waitingQueue;  //正在加入会话
    NSString * _pubViewId;
    dispatch_queue_t _callQueue;
}
static HDAgoraCallManager *shareCall = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareCall = [[HDAgoraCallManager alloc] init];
    });
    return shareCall;
}
#pragma mark - base
- (instancetype)init {
    self = [super init];
    if (self) {
        _delegates = [[HDGCDMulticastDelegate<HDAgoraCallManagerDelegate> alloc] init];
        _cacheStreams = [NSMutableDictionary dictionaryWithCapacity:0];
        _waitingQueue = [NSMutableArray arrayWithCapacity:0];
        _onCalling = NO;
        _callQueue = dispatch_queue_create("com.helpdesk.agoracall.queue", NULL);
    }
    return self;
}

- (NSDictionary *)getAgentCallOptions{
    
    return [[HLCallManager sharedInstance] getAgentTicketCallOptions];
    
}
- (NSDictionary *)getVisitorCallOptions{
    
    return [[HLCallManager sharedInstance] getVisitorTicketCallOptions];
}

- (void)setCallOptions:(HDAgoraCallOptions *)aOptions{
    
    _options = aOptions;
 
    [self setCustomerAgoraCallParameter];
}

/// 设置自定义的 声网加入视频参数
- (void)setCustomerAgoraCallParameter{
    NSDictionary * dic = _options.extension;
    if (dic) {
        if ([dic isDictionaryContainsKey:kSaveAgoraToken] &&[dic isDictionaryContainsKey:kSaveAgoraChannel] &&[dic isDictionaryContainsKey:kSaveAgoraAppID] ) {
            //如果都存在 取出 设置自定义 参数
            HDKeyCenter *key = [[HDKeyCenter alloc] init];
            key.agoraToken = [dic valueForKey:kSaveAgoraToken];
            key.agoraAppid = [dic valueForKey:kSaveAgoraAppID];
            key.agoraChannel = [dic valueForKey:kSaveAgoraChannel];
            _keyCenter = key;
            //存储参数等待 其他app 使用
            [self saveAppKeyCenter:key];
        }
    }
}
- (HDAgoraCallOptions *)getCallOptions{
    
    return _options;
}
#pragma mark - add,remove delegate

- (void)addDelegate:(id<HDAgoraCallManagerDelegate>)aDelegate delegateQueue:(dispatch_queue_t)aQueue {
    if (aQueue == nil) {
        aQueue = dispatch_get_main_queue();
    }
    [_delegates addDelegate:aDelegate delegateQueue:aQueue];
}

- (void)removeDelegate:(id<HDAgoraCallManagerDelegate>)aDelegate {
    [_delegates removeDelegate:aDelegate];
}
#pragma mark - 收到消息代理
- (void)messagesDidReceive:(NSArray *)aMessages{
     //收到普通消息,格式:<HDMessage *>
    if (aMessages.count == 0) {
        return;
    }
    for (EMMessage *msg in aMessages) {
//        [DDLog logI:@"messagesDidReceive aMessages ext %@=",msg.ext];
        if (msg.ext) {
            NSDictionary *dic = [msg.ext objectForKey:@"msgtype"];
            if (dic) {
                if ([dic isDictionaryContainsKey: @"videoPlayback"]) {
                    
                   NSDictionary  *videoPlaybackDic = [dic getDictionaryValue:@"videoPlayback"];
                    
                    NSString *  msg  = (NSString *) [videoPlaybackDic getDictionaryValue:@"msg"];
                
                    if([msg isEqualToString:@"playback"]){
                        
                        NSDictionary *  videoObjDic  = [videoPlaybackDic getDictionaryValue:@"videoObj"];
                        NSString *  callId ;
                        if([videoObjDic isDictionaryContainsKey: @"callId"]){
                            
                            callId  = (NSString *) [videoPlaybackDic getDictionaryValue:@"callId"];
                        }
                        //调用挂掉视频操作
                        [self agentHangUpCall:callId];
                        return;
                    }
                }
            }
        }
    }
}
#pragma mark - 懒加载

- (AgoraRtcEngineKit *)agoraKit {
    if (!_agoraKit) {
        _agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:_keyCenter.agoraAppid delegate:self];
        //设置频道场景
        [_agoraKit setChannelProfile:AgoraChannelProfileLiveBroadcasting];
        //设置角色
        [_agoraKit setClientRole:AgoraClientRoleBroadcaster];
        //启用视频模块
        [_agoraKit enableVideo];
    
        //开启虚拟背景
//        AgoraVirtualBackgroundSource *backgroundSource = [[AgoraVirtualBackgroundSource alloc] init];
//        backgroundSource.backgroundSourceType = AgoraVirtualBackgroundColor;
//        [_agoraKit enableVirtualBackground:NO backData:backgroundSource];
        //开启enableDeepLearningDenoiseSDK 默认开启传统降噪，以消除大部分平稳噪声。AI 降噪是指在传统降噪的基础上消除非平稳噪声。集成 AI 降噪插件后，你可以调用 enableDeepLearningDenoise 开启 AI 降噪
        [_agoraKit enableDeepLearningDenoise:YES];
        // set video configuration
        float size = _options.dimension.width;
        AgoraVideoEncoderConfiguration *configuration = [[AgoraVideoEncoderConfiguration alloc] initWithSize:  (size>0 ? _options.dimension : AgoraVideoDimension360x360) frameRate:_options.frameRate ? AgoraVideoFrameRateFps24 : (AgoraVideoFrameRate)_options.frameRate bitrate:_options.bitrate ? _options.bitrate :AgoraVideoBitrateStandard  orientationMode:_options.orientationMode ? (AgoraVideoOutputOrientationMode)_options.orientationMode :AgoraVideoOutputOrientationModeAdaptative];
        
        [_agoraKit setVideoEncoderConfiguration:configuration];
        
        //是否静音
        [_agoraKit muteLocalAudioStream:_options.mute];
        //是否关闭摄像头
        [_agoraKit muteLocalVideoStream:_options.videoOff];
        [[HDClient sharedClient].chatManager addDelegate:self delegateQueue:_callQueue];
    }
    return _agoraKit;
}
#pragma mark - 设置相关
- (void)setEnableVirtualBackground:(BOOL)enable{
    
    AgoraVirtualBackgroundSource *backgroundSource = [[AgoraVirtualBackgroundSource alloc] init];
    backgroundSource.backgroundSourceType = AgoraVirtualBackgroundColor;
    [self.agoraKit enableVirtualBackground:enable backData:backgroundSource];
}
- (void)setupLocalVideoView:(UIView *)localView{
    
    AgoraRtcVideoCanvas * canvas = [[AgoraRtcVideoCanvas alloc] init];
    canvas.uid = _options.uid;
    canvas.view = localView;
    canvas.renderMode = AgoraVideoRenderModeHidden;
    [self.agoraKit setupLocalVideo:canvas];
    [self.agoraKit startPreview];
    
}
- (void)setupRemoteVideoView:(UIView *)remoteView withRemoteUid:(NSInteger)uid{
    AgoraRtcVideoCanvas * canvas = [[AgoraRtcVideoCanvas alloc] init];
    canvas.uid = uid;
    canvas.view = remoteView;
    canvas.renderMode = AgoraVideoRenderModeHidden;
    [self.agoraKit setupRemoteVideo:canvas];
    [self.agoraKit startPreview];
    
}

#pragma mark - 音视频事件

- (void)switchCamera{
    
    [self.agoraKit switchCamera];
}
- (void)pauseVoice{
    
    [self.agoraKit muteLocalAudioStream:YES];
}

- (void)resumeVoice{
    
    [self.agoraKit muteLocalAudioStream:NO];
    
}
- (void)pauseVideo{
    [self.agoraKit  muteLocalVideoStream:YES];
}
- (void)resumeVideo{
    [self.agoraKit  muteLocalVideoStream:NO];
    
}
/**
 * 发起视频邀请，
 */
- (HDMessage *)creteVideoInviteMessageWithSessionId:(NSString *)sessionId
                                                 to:(NSString *)toUser
                                           WithText:(NSString *)text {
    
    HDTextMessageBody *body = [[HDTextMessageBody alloc] initWithText:text];
    HDMessage *message = [[HDMessage alloc] initWithSessionId:sessionId to:toUser messageBody:body];
    NSDictionary *dic = @{
                          @"type":@"agorartcmedia/video",
                          @"msgtype":@{
                                  @"liveStreamInvitation":@{
                                          @"resource": @"mobile",
                                          @"msg": @"邀请访客进行视频",
                                          @"isNewInvitation":@(YES)
                                          }
                                  }
                          };
    message.ext = [[MessageExtModel alloc] initWithDictionary:dic];
    return message;
}
- (void)endCall{
    [self.agoraKit leaveChannel:nil];
    if(_keyCenter.callid >0){
  
    }
    //该方法为同步调用，需要等待 AgoraRtcEngineKit 实例资源释放后才能执行其他操作，所以我们建议在子线程中调用该方法，避免主线程阻塞。此外，我们不建议 在 SDK 的回调中调用 destroy，否则由于 SDK 要等待回调返回才能回收相关的对象资源，会造成死锁。
    [self destroy];
}

/// 坐席主动挂断视频
/// @param callid  呼叫id
- (void)agentHangUpCall:(NSString *)callid{
    
    //移除消息监控
    [[HDClient sharedClient].chatManager removeDelegate:self];
    [self.agoraKit leaveChannel:nil];
//    [_delegates onCallEndReason:HDErrorCallReasonHangup desc:@"reason-conference-dismissed"];
    [self destroy];
}
- (void)endRecord{
    // 结束录制
    [[HLCallManager sharedInstance] stopAgoraRtcRecodCallId:_keyCenter.callid withSessionId:[HDAgoraCallManager shareInstance].sessionId];
}

- (int)startPreview{
    return [self.agoraKit startPreview];
}
- (int)stopPreview{
    
    return [self.agoraKit stopPreview];
}
- (void)destroy{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [AgoraRtcEngineKit destroy];
    });
    
    self.agoraKit = nil;
    self.agoraKitScreenShare = nil;
    //结束录制
    [self endRecord];
}
- (void)setEnableSpeakerphone:(BOOL)enableSpeaker{
    
    [self.agoraKit setEnableSpeakerphone:enableSpeaker];
    
}
- (NSArray *)hasJoinedMembers {
    return self.members;
}

/*
  这个地方是 创建 坐席加入房间 必要参数
 */
- (void)createTicketDidReceiveAgoraInit {
        //1、发消息获取callid
        //2、拿到callid 调用获取视频通行证信息接口
        //3、封装拿到的参数给访客端 使用 并发送消息 以及 本身使用参数存储
    //接收到坐席发来的消息获取token appid channel 等必要字段
        NSString *token;
        NSString *appId;
        NSString *channel;
        NSString *uid;
        NSString *callId;
    token = kToken;
    appId = kAPPid;
    channel = kChannelName;
    //初始化 声网参数
    HDKeyCenter *key = [[HDKeyCenter alloc] init];
    HDAgoraTicketModel * model = [HDAgoraTicketModel yy_modelWithDictionary:[self getAgentCallOptions]];
    if (model) {
        key.agoraToken = model.token;
        key.agoraAppid = model.appId;
        key.agoraChannel = model.channel;
        key.agoraUid = model.uid;
        key.callid = model.callId;
        _keyCenter = key;
    }else{
        //初始化 声网参数
        HDKeyCenter *key = [[HDKeyCenter alloc] init];
        key.agoraToken = token;
        key.agoraAppid = appId;
        key.agoraChannel = channel;
        key.agoraUid = uid;
        key.callid = callId;
        _keyCenter = key;
        
    }
    //存储参数等待 其他app 使用
    [self saveAppKeyCenter:key];
}
/**
 接受视频会话

 @param nickname 传递自己的昵称到对方
 @param completion 完成回调
 */
- (void)hd_joinCallWithNickname:(NSString *)nickname completion:(void (^)(id, HDError *))completion{
    self.Completion = completion;
    [self hd_joinChannelByToken:_keyCenter.agoraToken channelId:_keyCenter.agoraChannel info:nil uid:_options.uid joinSuccess:^(NSString * _Nullable channel, NSUInteger uid, NSInteger elapsed) {
//        [HDLog logI:@"joinSuccess channel=%@  uid=%lu",channel,(unsigned long)uid];
        //加入成功以后 开始 录制
        [[HLCallManager sharedInstance] startAgoraRtcRecodCallId:_keyCenter.callid withSessionId: [HDAgoraCallManager shareInstance].sessionId];
        self.Completion(nil, nil);
    }];
    
    [[HLCallManager sharedInstance] startAgoraRtcRecodCallId:_keyCenter.callid withSessionId: [HDAgoraCallManager shareInstance].sessionId];
}
- (void)hd_joinChannelByToken:(NSString *)token channelId:(NSString *)channelId info:(NSString *)info uid:(NSUInteger)uid joinSuccess:(void (^)(NSString * _Nullable, NSUInteger, NSInteger))joinSuccessBlock{
    
    [self.agoraKit joinChannelByToken: token channelId: channelId info:info uid: uid  joinSuccess:joinSuccessBlock];
}
- (HDAgoraCallMember *)getHDAgoraCallMember:(NSUInteger )uid {
    
    NSMutableDictionary * extensionDic =[NSMutableDictionary dictionaryWithDictionary:_ext];
    
    [extensionDic setValue:_nickName forKey:@"nickname"];
    
    HDAgoraCallMember *member = [[HDAgoraCallMember alloc] init];
    [member setValue:[NSString stringWithFormat:@"%lu",(unsigned long)uid] forKeyPath:@"memberName"];
    [member setValue:extensionDic forKeyPath:@"extension"];
    return member;
}
#pragma mark - <AgoraRtcEngineDelegate>
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    
    //先判断是不是 屏幕分享用户
    if([self isScreenShareUid:uid]) {
        
//        [HDLog logI:@"Ignore screen share uid== %lu",(unsigned long)uid];
        return;
    }
    NSLog(@"join Member  uid---- %lu ",(unsigned long)uid);
    HDAgoraCallMember *mem = [self getHDAgoraCallMember:uid];
    @synchronized(_members){
        BOOL isNeedAdd = YES;
        for (HDAgoraCallMember *member in self.members) {
            if ([mem.memberName isEqualToString:member.memberName]) {
                isNeedAdd = NO;
                break;
            }
        }
        if (isNeedAdd) {
            [self.members addObject:mem];
        }
    };
    [_delegates onMemberJoin:mem];
    [_delegates hd_rtcEngine:self didJoinedOfUid:uid elapsed:elapsed];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine remoteVideoStateChangedOfUid:(NSUInteger)uid state:(AgoraVideoRemoteState)state reason:(AgoraVideoRemoteStateReason)reason elapsed:(NSInteger)elapsed
{
    
//    [_delegates rtcRemoteVideoStateChangedOfUid:uid state:state reason:@"1234" elapsed:elapsed];
  
    NSLog(@"remoteVideoStateChangedOfUid %@ %@ %@", @(uid), @(state), @(reason));
}
///  Occurs when the local user joins a specified channel.
/// @param engine - RTC engine instance
/// @param channel  - Channel name
/// @param uid - User ID of the remote user sending the video stream.
/// @param elapsed - Time elapsed (ms) from the local user calling the joinChannelByToken method until the SDK triggers this callback.
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinChannel:(NSString *)channel withUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
//    [self info:[NSString stringWithFormat:@"Join channel: %@", channel]];
    
    
}


/// Occurs when the connection between the SDK and the server is interrupted.
/// The SDK triggers this callback when it loses connection with the server for more than four seconds after a connection is established.
/// After triggering this callback, the SDK tries reconnecting to the server. You can use this callback to implement pop-up reminders.
/// @param engine - RTC engine instance
- (void)rtcEngineConnectionDidInterrupted:(AgoraRtcEngineKit *)engine {
//    [self alert:@"Connection Interrupted"];
}

/// Occurs when the SDK cannot reconnect to Agora’s edge server 10 seconds after its connection to the server is interrupted.
/// @param engine - RTC engine instance
- (void)rtcEngineConnectionDidLost:(AgoraRtcEngineKit *)engine {
//    [self alert:@"Connection Lost"];
    
    [_delegates hd_rtcEngineConnectionDidLost:self];

}
/// Reports an error during SDK runtime.
/// @param engine - RTC engine instance
/// @param errorCode - see complete list on this page
///         https://docs.agora.io/en/Video/API%20Reference/oc/Constants/AgoraErrorCode.html
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurError:(AgoraErrorCode)errorCode {
    HDError *dhError = [[HDError alloc] initWithDescription:@"Occur error " code:(HDErrorCode)errorCode];
    !self.Completion?:self.Completion(nil,dhError);
    [_delegates hd_rtcEngine:self didOccurError:dhError];
}

/// 已完成远端视频首帧解码回调
/// @param agoraCallManager agoraCallManager instance
/// @param uid 远端用户 ID
/// @param size 视频流尺寸（宽度和高度）
/// @param elapsed 从本地用户调用 joinChannelByToken到发生此事件过去的时间（ms）。
- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed {
    
    [_delegates hd_rtcEngine:self firstRemoteVideoDecodedOfUid:uid size:size elapsed:elapsed];
    
}

/// 已显示本地视频首帧的回调
/// @param engine - RTC engine instance
/// @param size 本地渲染的视频尺寸（宽度和高度）
/// @param elapsed 从本地用户调用joinChannelByToken到发生此事件过去的时间（ms）。如果在joinChannelByToken前调用了startPreview，是从 startPreview 到发生此事件过去的时间。
- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstLocalVideoFrameWithSize:(CGSize)size elapsed:(NSInteger)elapsed {
    [_delegates hd_rtcEngine:self firstLocalVideoFrameWithSize:size elapsed:elapsed];
}

/// 远端用户（通信场景）/主播（直播场景）离开当前频道回调
/// @param engine engine
/// @param uid 离线的用户 ID。
/// @param reason 离线原因
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason{
   
    HDAgoraCallMember *mem = [self getHDAgoraCallMember:uid];
    HDAgoraCallMember *needRemove = nil;
    @synchronized(_members){
        for (HDAgoraCallMember *_member in self.members) {
            if ([_member.memberName isEqualToString:mem.memberName]) {
                needRemove = _member;
            }
        }
        if (needRemove) {
            [self.members removeObject:needRemove];
        }
    };
    [_delegates onMemberExit:mem];
    
    [_delegates hd_rtcEngine:self didOfflineOfUid:uid reason:(HDAgoraUserOfflineReason)reason];
}
- (void)rtcEngine:(AgoraRtcEngineKit *)engine virtualBackgroundSourceEnabled:(BOOL)enabled reason:(AgoraVirtualBackgroundSourceStateReason)reason{
    
//    [HDLog logI:@"virtualBackgroundSourceEnabled = %d = reason=%luu",enabled,(unsigned long)reason];
    
}

#pragma mark - AgoraRtcEngineKit 屏幕分享 相关
/// 保持动态数据 给其他app 进程通信
/// @param keyCenter 对象参数
- (void)saveAppKeyCenter:(HDKeyCenter *)keyCenter{

    [HDSSKeychain setPassword: keyCenter.agoraAppid forService:kForService account:kSaveAgoraAppID];
    [HDSSKeychain setPassword: keyCenter.agoraToken forService:kForService account:kSaveAgoraToken];
    [HDSSKeychain setPassword: keyCenter.agoraChannel forService:kForService account:kSaveAgoraChannel];
    if (_options.shareUid > 0) {
        keyCenter.shareUid = [NSString stringWithFormat:@"%lud",_options.shareUid];
        [HDSSKeychain setPassword: keyCenter.shareUid forService:kForService account:kSaveAgoraShareUID];
    }
}
- (HDKeyCenter *)getAppKeyCenter{
    HDKeyCenter * keycenter= [[HDKeyCenter  alloc] init];
    keycenter.agoraAppid =  [HDSSKeychain passwordForService:kForService account:kSaveAgoraAppID];
    keycenter.agoraToken =  [HDSSKeychain passwordForService:kForService account:kSaveAgoraToken];
    keycenter.agoraChannel =  [HDSSKeychain passwordForService:kForService account:kSaveAgoraChannel];
    keycenter.shareUid =  [HDSSKeychain passwordForService:kForService account:kSaveAgoraShareUID];

    return  keycenter;
}
- (NSArray *)getBroadcastParameter{
    HDKeyCenter * keycenter = [self getAppKeyCenter];
    NSMutableArray * mArray =  [NSMutableArray array];
    [mArray addObject:keycenter.agoraAppid];
    [mArray addObject:keycenter.agoraToken];
    [mArray addObject:keycenter.agoraChannel];
    [mArray addObject:keycenter.shareUid];
    
    return  mArray;
}
- (BOOL)isScreenShareUid:(NSUInteger)uid{
    HDKeyCenter * shareKey = [self getAppKeyCenter];
    if (shareKey.shareUid.length > 0) {
        if (uid == [shareKey.shareUid integerValue]) {
            return  YES;
        }
        return  NO;
    }
    return uid >= SCREEN_SHARE_UID_MIN && uid <= SCREEN_SHARE_UID_MAX;
}
- (void)startBroadcast{
    //存储状态 1 是开始。2 是 停止
    [HDSSKeychain setPassword:@"1"  forService:kForService account:kSaveScreenShareState];
    HDKeyCenter * shareKey = [self getAppKeyCenter];
    [self.agoraKitScreenShare joinChannelByToken:shareKey.agoraToken channelId:shareKey.agoraChannel info:nil uid:[HDAgoraCallManager getScreenShareUid] joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
//        [HDLog  logI:@"agora - join success =uid=%lu  channel%@=",(unsigned long)uid,channel];
    }];
}

- (AgoraRtcEngineKit *)agoraKitScreenShare {
    if (!_agoraKitScreenShare) {
        //创建 AgoraRtcEngineKit 实例
        HDKeyCenter * shareKey = [self getAppKeyCenter];
        _agoraKitScreenShare = [AgoraRtcEngineKit sharedEngineWithAppId:shareKey.agoraAppid delegate:nil];
        //设置频道场景
        [_agoraKitScreenShare setChannelProfile:AgoraChannelProfileLiveBroadcasting];
        //设置角色
        [_agoraKitScreenShare setClientRole:AgoraClientRoleBroadcaster];
        //启用视频模块
        [_agoraKitScreenShare enableVideo];
        //音频
        [_agoraKitScreenShare disableAudio];
        //视频自采集 (仅适用于 push 模式)
        [_agoraKitScreenShare setExternalVideoSource:YES useTexture:YES pushMode:YES];
        //初始化并返回一个新分配的具有指定视频分辨率的AgoraVideoEncoderConfiguration对象。
        AgoraVideoEncoderConfiguration *configuration = [[AgoraVideoEncoderConfiguration alloc] initWithSize:[self videoDimension]
                       frameRate:AgoraVideoFrameRateFps24 bitrate:AgoraVideoBitrateStandard orientationMode:AgoraVideoOutputOrientationModeAdaptative];
        [_agoraKitScreenShare setVideoEncoderConfiguration:configuration];

        //设置音频编码配置
        [_agoraKitScreenShare setAudioProfile: AgoraAudioProfileMusicStandardStereo scenario:AgoraAudioScenarioDefault];

        //设置采集的音频格式
        [_agoraKitScreenShare setRecordingAudioFrameParametersWithSampleRate:audioSampleRate channel:audioChannels mode:AgoraAudioRawFrameOperationModeReadWrite samplesPerCall:1024];
        //多人通信场景的优化策略
        [ _agoraKitScreenShare setParameters:@"{\"che.audio.external_device\":true}"];
        [ _agoraKitScreenShare setParameters:@"{\"che.hardware_encoding\":1}"];
        [ _agoraKitScreenShare setParameters:@"{\"che.video.enc_auto_adjust\":0}"];
        //取消或恢复订阅所有远端用户的音频流。
        [_agoraKitScreenShare muteAllRemoteAudioStreams:YES];
        //取消或恢复订阅所有远端用户的视频流。
        [_agoraKitScreenShare muteAllRemoteVideoStreams:YES];
    }
    return _agoraKitScreenShare;
}
- (CGSize)videoDimension{

    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    CGSize boundingSize = CGSizeMake(720, 1280);
    float mW = boundingSize.width / screenSize.width;
    float mH = boundingSize.height / screenSize.height;
    if( mH < mW ) {
        boundingSize.width = boundingSize.height / screenSize.height * screenSize.width;
    }else if( mW < mH ) {
        boundingSize.height = boundingSize.width / screenSize.width * screenSize.height;
    }
    return boundingSize;
}
+ (NSUInteger)getScreenShareUid{
    HDKeyCenter * shareKey = [[HDAgoraCallManager shareInstance] getAppKeyCenter];
    if (shareKey.shareUid.length > 0) {
        return  [shareKey.shareUid integerValue];
    }
    NSUInteger randomUid = (NSUInteger)arc4random_uniform(SCREEN_SHARE_UID_MAX - SCREEN_SHARE_UID_MIN + 1) + SCREEN_SHARE_UID_MIN;
    return  randomUid;
}
- (void)stopBroadcast{
    
    //存储状态 1 是开始。2 是 停止
    [HDSSKeychain setPassword:@"2"  forService:kForService account:kSaveScreenShareState];
    [self.agoraKitScreenShare leaveChannel:nil];
}
- (BOOL)getBroadcastState{
    //获取 录屏状态
    NSString * state =  [HDSSKeychain passwordForService:kForService account:kSaveScreenShareState];
    if ([state intValue] == 1) {
        return  YES;
    }else{
        
        return NO;
    }
    
}
-(void)sendVideoBuffer:(CMSampleBufferRef)sampleBuffer{
    CVImageBufferRef videoFrame = CMSampleBufferGetImageBuffer(sampleBuffer);
        if (videoFrame == nil) {
            return;
        }
        int rotation = 0;
        if (@available(iOS 11.0, *)) {
            NSNumber * orientation = CMGetAttachment(sampleBuffer, (CFStringRef)RPVideoSampleOrientationKey, nil);
            CGImagePropertyOrientation ori = orientation.intValue;
            switch (ori) {
                case kCGImagePropertyOrientationUp:
                case kCGImagePropertyOrientationUpMirrored:
                    rotation = 0;
                    break;
                case kCGImagePropertyOrientationDown:
                case kCGImagePropertyOrientationDownMirrored:
                    rotation = 180;
                    break;
                case kCGImagePropertyOrientationLeft:
                case kCGImagePropertyOrientationLeftMirrored:
                    rotation = 90;
                    break;
                case kCGImagePropertyOrientationRight:
                case kCGImagePropertyOrientationRightMirrored:
                    rotation = 270;
                    break;
                default:
                    break;
            }
            CMTime time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            AgoraVideoFrame * frame = [AgoraVideoFrame new];
            frame.format = 12;
            frame.time = time;
            frame.textureBuf = videoFrame;
            frame.rotation =rotation;
            [self.agoraKitScreenShare pushExternalVideoFrame:frame];

        }
}

- (AgoraRtcEngineKit *)getBroadcastRtcEngine{

    return  self.agoraKitScreenShare;
}

#pragma mark -  声网音视频 接口 相关



@end
