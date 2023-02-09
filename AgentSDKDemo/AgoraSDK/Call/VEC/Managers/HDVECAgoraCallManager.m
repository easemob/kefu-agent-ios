//
//  HDAgoraCallManager.m
//  HelpDeskLite
//
//  Created by houli on 2022/1/6.
//  Copyright © 2022 hyphenate. All rights reserved.
//

#import "HDVECAgoraCallManager.h"
#import <ReplayKit/ReplayKit.h>
#import <CoreMedia/CoreMedia.h>
#import "HDVECAgoraCallMember.h"
#import "HDVECAgoraTicketModel.h"
#import "HDSanBoxFileManager.h"
#define kToken @"00674855635d3a64920b0c7ee3684f68a9fIACA8a3yaqUdWNcyB5POBY85dP6+vnuMp8fVlCcFYHwStBo6pkUAAAAAEAD45Mp2OAPyYQEAAQA4A/Jh";
#define kAPPid  @"74855635d3a64920b0c7ee3684f68a9f";
#define kChannelName @"huanxin"

#define kForService @"com.easemob.enterprise.demo.kefuapp.AgentSDKDemoShareExtension"
#define kSaveAgoraToken @"call_agoraToken"
#define kSaveAgoraChannel @"call_agoraChannel"
#define kSaveAgoraAppID @"call_agoraAppid"
#define kSaveAgoraShareUID @"call_agoraShareUID"
#define kSaveAgoraCallId @"call_agoraCallId"

// 存放屏幕分享的状态
#define kSaveScreenShareState @"Easemob_ScreenShareState"
//static NSInteger audioSampleRate = 48000;
//static NSInteger audioChannels = 2;
//static uint32_t SCREEN_SHARE_UID_MIN  = 501;
//static uint32_t SCREEN_SHARE_UID_MAX  = 1000;

@interface HDVECAgoraCallManager () <AgoraRtcEngineDelegate,HDChatManagerDelegate>
{
    HDVECAgoraCallOptions *_options;
    AgoraRtcVideoCanvas *_canvas;
    NSString *_nickName;
    NSDictionary *_ext;
    NSString *_ticket;


    
    BOOL _isSetupLocalVideo; //判断是否已经设置过了；
    
    
    NSInteger _visitorUid;
}

@property (nonatomic, strong) NSMutableArray *members;

@property (nonatomic, strong) AgoraRtcEngineKit *agoraKitScreenShare;
@property (nonatomic, copy) void (^Completion)(id, HDError *)  ;


@end
@implementation HDVECAgoraCallManager
{
    BOOL _onCalling; //正在通话
    NSMutableDictionary *_cacheStreams; //没有点击接受的时候缓存的stream
    NSMutableArray *_waitingQueue;  //正在加入会话
    NSString * _pubViewId;
    dispatch_queue_t _callQueue;
}
static HDVECAgoraCallManager *shareCall = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareCall = [[HDVECAgoraCallManager alloc] init];
       
    });
    return shareCall;
}


#pragma mark - base
- (instancetype)init {
    self = [super init];
    if (self) {
        _cacheStreams = [NSMutableDictionary dictionaryWithCapacity:0];
        _waitingQueue = [NSMutableArray arrayWithCapacity:0];
        _onCalling = NO;
        _callQueue = dispatch_queue_create("com.easemob.kefuapp.vec.queue", NULL);
        //添加消息监听
        [[HDClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
        
        
    }
    return self;
}

- (void)setCallOptions:(HDVECAgoraCallOptions *)aOptions{
    _options = aOptions;
}
- (HDVECAgoraCallOptions *)getCallOptions{
    
    return _options;
}

#pragma mark - 收到消息代理
- (void)messagesDidReceive:(NSArray *)aMessages{
     //收到普通消息,格式:<HDMessage *>
    if (aMessages.count == 0) {
        return;
    }
    for (EMMessage *msg in aMessages) {
        if (msg.ext) {
            NSDictionary *dic = [msg.ext objectForKey:@"msgtype"];
            if (dic) {
                if ([[dic allKeys] containsObject: @"videoPlayback"]) {
                    
                   NSDictionary  *videoPlaybackDic = [dic valueForKey:@"videoPlayback"];
                    
                    NSString *  msg  = (NSString *) [videoPlaybackDic valueForKey:@"msg"];
                
                    if([msg isEqualToString:@"playback"]){
                        
                        NSDictionary *  videoObjDic  = [videoPlaybackDic valueForKey:@"videoObj"];
                        NSString *  callId ;
                        if([[videoObjDic allKeys] containsObject: @"callId"]){
                            
                            callId  = (NSString *) [videoPlaybackDic valueForKey:@"callId"];
                        }
                        //调用挂掉视频操作
//                        [self agentHangUpCall:callId];
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
        _agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId: [HDVECAgoraCallManager shareInstance].keyCenter.agoraAppid delegate:self];
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
        
         
//        _options.dimension = CGSizeMake( [UIScreen mainScreen].bounds.size, [UIScreen mainScreen].bounds.h)
        
        
        AgoraVideoEncoderConfiguration *configuration = [[AgoraVideoEncoderConfiguration alloc] initWithSize:  (size>0 ? _options.dimension : AgoraVideoDimension480x480) frameRate:_options.frameRate ? AgoraVideoFrameRateFps24 : (AgoraVideoFrameRate)_options.frameRate bitrate:_options.bitrate ? _options.bitrate :AgoraVideoBitrateStandard  orientationMode:_options.orientationMode ? (AgoraVideoOutputOrientationMode)_options.orientationMode :AgoraVideoOutputOrientationModeAdaptative];
        
        [_agoraKit setVideoEncoderConfiguration:configuration];
        

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
    
    //这个地方添加判断是 为了防止调用setupLocalVideo 多次导致本地view 卡死
    if (_isSetupLocalVideo) {
        return;
    }
    _isSetupLocalVideo = YES;
    NSLog(@"======setupLocalVideoView");
    AgoraRtcVideoCanvas * canvas = [[AgoraRtcVideoCanvas alloc] init];
    canvas.uid = [[HDVECAgoraCallManager shareInstance].keyCenter.agoraUid integerValue];
    canvas.view = localView;
    canvas.renderMode = AgoraVideoRenderModeHidden ;
    [self.agoraKit setupLocalVideo:canvas];
    [self.agoraKit startPreview];
    
}
- (void)setupRemoteVideoView:(UIView *)remoteView withRemoteUid:(NSInteger)uid{
    NSLog(@"======setupRemoteVideoView");
    AgoraRtcVideoCanvas * canvas = [[AgoraRtcVideoCanvas alloc] init];
    canvas.uid = uid;
    canvas.view = remoteView;
    canvas.renderMode = AgoraVideoRenderModeFit;
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
- (void)enableLocalVideo:(BOOL)enabled{
    
    [self.agoraKit  enableLocalVideo:enabled];
}
- (void)pauseVideo{
    [self.agoraKit  muteLocalVideoStream:YES];
}
- (void)resumeVideo{
    
    [self.agoraKit  muteLocalVideoStream:NO];
}

- (void)leaveChannel{
    _isSetupLocalVideo = NO;
    [self.agoraKit leaveChannel:nil];
    [_members removeAllObjects];
    //结束录制
    [self endRecord];
    [HDVECAgoraCallManager shareInstance].isCurrentCalling = NO;
}
- (void)joinChannel{
    [self hd_joinChannelByToken:[HDVECAgoraCallManager shareInstance].keyCenter.agoraToken channelId:[HDVECAgoraCallManager shareInstance].keyCenter.agoraChannel info:nil uid:[[HDVECAgoraCallManager shareInstance].keyCenter.agoraUid integerValue] joinSuccess:^(NSString * _Nullable channel, NSUInteger uid, NSInteger elapsed) {
        _onCalling = YES;
        NSLog(@"joinSuccess joinChannelByToken channel=%@  uid=%lu",channel,(unsigned long)uid);
    }];
    
}
//- (void)endCall{
//
//    //发送透传消息cmd。
//    EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:@"Agorartcmedia"];
//    NSString *from = [[HDClient sharedClient] currentUsername];
//    HDMessage *message = [[HDMessage alloc] initWithConversationID:[[HDCallManager shareInstance] conversationId] from:from to:[[HDCallManager shareInstance] conversationId] body:body];
//    NSDictionary *dic = @{
//                          @"type":@"agorartcmedia/video",
//                          @"msgtype":@{
//                                  @"visitorCancelInvitation":@{
//                                      @"callId":[HDAgoraCallManager shareInstance].keyCenter.callid>0 ?[HDAgoraCallManager shareInstance].keyCenter.callid : [NSString stringWithFormat:@"null"]
//                                          }
//                                  }
//                          };
//    message.ext = dic;
//
//
//
//    [[HDClient sharedClient].chatManager sendMessage:message progress:nil completion:^(HDMessage *aMessage, HDError *aError) {
//
//        NSLog(@"===%@",aError);
//
//    }];
//
//    [self leaveChannel];
//
//    //该方法为同步调用，需要等待 AgoraRtcEngineKit 实例资源释放后才能执行其他操作，所以我们建议在子线程中调用该方法，避免主线程阻塞。此外，我们不建议 在 SDK 的回调中调用 destroy，否则由于 SDK 要等待回调返回才能回收相关的对象资源，会造成死锁。
//    [self destroy];
//}
- (void)endCall{
  
    [self leaveChannel];
    //该方法为同步调用，需要等待 AgoraRtcEngineKit 实例资源释放后才能执行其他操作，所以我们建议在子线程中调用该方法，避免主线程阻塞。此外，我们不建议 在 SDK 的回调中调用 destroy，否则由于 SDK 要等待回调返回才能回收相关的对象资源，会造成死锁。
    [self destroy];
}


- (void)refusedCall{
    
    //发送透传消息cmd
//    EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:@"Agorartcmedia"];
//    NSString *from = [[HDClient sharedClient] currentUsername];
//    HDMessage *message = [[HDMessage alloc] initWithConversationID:[[HDCallManager shareInstance] conversationId] from:from to:[[HDCallManager shareInstance] conversationId] body:body];
//    NSDictionary *dic = @{
//                          @"type":@"agorartcmedia/video",
//                          @"msgtype":@{
//                                  @"visitorRejectInvitation":@{
//                                          @"callId":[HDAgoraCallManager shareInstance].keyCenter.callid>0 ?[HDAgoraCallManager shareInstance].keyCenter.callid : [NSString stringWithFormat:@"null"]
//                                          }
//                                  }
//                          };
//    message.ext = dic;
//
//    [[HDClient sharedClient].chatManager sendMessage:message progress:nil completion:^(HDMessage *aMessage, HDError *aError) {
//
//        NSLog(@"===%@",aError);
//
//    }];
    [self leaveChannel];
    
    //该方法为同步调用，需要等待 AgoraRtcEngineKit 实例资源释放后才能执行其他操作，所以我们建议在子线程中调用该方法，避免主线程阻塞。此外，我们不建议 在 SDK 的回调中调用 destroy，否则由于 SDK 要等待回调返回才能回收相关的对象资源，会造成死锁。
    [self destroy];
}
/// 坐席主动挂断视频
/// @param callid  呼叫id
- (void)agentHangUpCall:(NSString *)callid{
    
    if (self.members.count != 0 ) {
        
        return;
    }
    
    if([self.roomDelegate respondsToSelector:@selector(onCallEndReason:desc:withRecordData:)]){
        
        [self.roomDelegate onCallEndReason:1 desc:@"reason-conference-dismissed"  withRecordData:nil];
    }
    //移除消息监控
    [[HDClient sharedClient].chatManager removeDelegate:self];
    [self leaveChannel];
    [self destroy];
}
- (int)startPreview{
    return [self.agoraKit startPreview];
}
- (int)stopPreview{
    
    return [self.agoraKit stopPreview];
}
- (void)destroy{
    _onCalling = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [AgoraRtcEngineKit destroy];
        self.agoraKit = nil;
        self.agoraKitScreenShare = nil;
    });
}
- (void)setEnableSpeakerphone:(BOOL)enableSpeaker{
    
    [self.agoraKit setEnableSpeakerphone:enableSpeaker];
    
}
- (NSArray *)hasJoinedMembers {
    return self.members;
}

- (NSMutableArray *)members{
    if (!_members) {
        _members = [[NSMutableArray alloc] init];
    }
    
    return _members;
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
    HDVECAgoraTicketModel * model = [HDVECAgoraTicketModel yy_modelWithDictionary:[self getAgentCallOptions]];
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
- (NSDictionary *)getAgentCallOptions{
    
    return [[HLCallManager sharedInstance] getAgentTicketCallOptions];
    
}
- (NSDictionary *)getVisitorCallOptions{
    
    return [[HLCallManager sharedInstance] getVisitorTicketCallOptions];
}
/**
 接受视频会话

 @param nickname 传递自己的昵称到对方
 @param completion 完成回调
 */
- (void)acceptCallWithNickname:(NSString *)nickname completion:(void (^)(id, HDError *))completion{
    self.Completion = completion;
    [HDLog logI:@"================vec1.2=====收到坐席回呼cmd消息 acceptCallWithNickname "];
    [self hd_joinChannelByToken:[HDVECAgoraCallManager shareInstance].keyCenter.agoraToken channelId:[HDVECAgoraCallManager shareInstance].keyCenter.agoraChannel info:nil uid:[[HDVECAgoraCallManager shareInstance].keyCenter.agoraUid integerValue] joinSuccess:^(NSString * _Nullable channel, NSUInteger uid, NSInteger elapsed) {
        _onCalling = YES;
        [HDLog logI:@"================vec1.2=====收到坐席回呼cmd消息 joinSuccess channel "];
        self.Completion(nil, nil);
        
        
        // 加入房间成功以后  给访客发消息
//        dispatch_async(dispatch_get_main_queue(), ^{
          
            [[HDClient sharedClient].hlCallManager kf_sendCmdMessage:[[HDClient sharedClient].hlCallManager getSendVisitorTicketWithVisitorNickname:_message.fromUser.nicename withVisitorTrueName:_message.fromUser.username] withSessionId:_message.sessionId withToUser:_message.from completion:^(HDMessage * _Nonnull message, HDError * _Nonnull error) {
                
                NSLog(@"=======%@",message);
                //加入成功以后 开始 录制
                [[HLCallManager sharedInstance] startAgoraRtcRecodCallId:_keyCenter.callid withSessionId: _message.sessionId];
            }];

//        });
       
        
        
    }];

}
- (void)hd_saveShareDeskData:(HDKeyCenter *)keyCenter{
    
    if (keyCenter) {
        
        [self saveAppKeyCenter:[HDVECAgoraCallManager shareInstance].keyCenter];
    }
    
}
- (void)endRecord{
    [HDVECAgoraCallManager shareInstance].isSender = NO;
    // 结束录制
    [[HLCallManager sharedInstance] stopAgoraRtcRecodCallId:_keyCenter.callid withSessionId:_message.sessionId completion:^(id  _Nonnull responseObject, HDError * _Nonnull error) {
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            //详情数据返回
            NSLog(@"responseObject = %@",responseObject);
            NSDictionary *dic = responseObject;
            NSString *status = [dic objectForKey:@"status"];
            if ([status isEqualToString:@"OK"] && [[dic allKeys] containsObject:@"entity"]) {
                
                NSDictionary * entity = [dic objectForKey:@"entity"];
                
                if ([[entity allKeys] containsObject:@"recordDetails"]) {
                    
                    //  解析数据
                    self.recordDetails = [NSArray yy_modelArrayWithClass:[KFVideoDetailModel class] json:[entity objectForKey:@"recordDetails"]];
        
                    if (self.recordDetails.count > 0) {
                        [self.recordDetails enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            KFVideoDetailModel * model = obj;
                            if ([model.callId isEqualToString:_keyCenter.callid]) {
                                
                            HDMessage * message  =   [[HLCallManager sharedInstance] kf_sendMessageVideoPlaybackSessionId:_message.sessionId withToUser:_message.from withVisitorName:_message.fromUser.nicename withVideoStartTime: [self timestrToTimeSecond:model.recordStart] withVideoEndTime: [self timestrToTimeSecond:model.recordEnd] withCallId:model.callId];
//
                                [[HDClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
                                        
                                } completion:^(HDMessage *aMessage, HDError *aError) {
                                        
                                    if (aError == nil) {
                                        // 发个通知 界面更新 视频录制
                                        [[NSNotificationCenter defaultCenter] postNotificationName:HDCALL_videoPlayback_end object:aMessage];
                                        _message = nil;
                                    }
                                   
                                }];
                                *stop = YES;
                            }
                            
                            
                        }];
                    }
                }
                
                
            }
            
           
//            if([self.roomDelegate respondsToSelector:@selector(onCallEndReason:desc:withRecordData:)]){
//
//                [self.roomDelegate onCallEndReason:1 desc:@"reason-conference-dismissed"  withRecordData:responseObject];
//            }
        }else{
          
//            if([self.roomDelegate respondsToSelector:@selector(onCallEndReason:desc:withRecordData:)]){
//
//                [self.roomDelegate onCallEndReason:1 desc:@"reason-conference-dismissed"  withRecordData:responseObject];
//            }
        }
    }];
}
- (NSString *)timestrToTimeSecond:(NSString *)timeStr {//timestr 豪秒
    NSTimeInterval interval = [timeStr doubleValue]/1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate: date];
    return dateString;
}
- (BOOL)getCallState{
    
    return  _onCalling;
    
}

- (void)hd_joinChannelByToken:(NSString *)token channelId:(NSString *)channelId info:(NSString *)info uid:(NSUInteger)uid joinSuccess:(void (^)(NSString * _Nullable, NSUInteger, NSInteger))joinSuccessBlock{
    
    [self.agoraKit joinChannelByToken: token channelId: channelId info:info uid: uid  joinSuccess:joinSuccessBlock];
}
- (HDVECAgoraCallMember *)getHDAgoraCallMember:(NSUInteger )uid {
    
    NSMutableDictionary * extensionDic =[NSMutableDictionary dictionaryWithDictionary:_ext];
    
    [extensionDic setValue:_message.fromUser.nicename forKey:@"nickname"];
    
    HDVECAgoraCallMember *member = [[HDVECAgoraCallMember alloc] init];
    [member setValue:[NSString stringWithFormat:@"%lu",(unsigned long)uid] forKeyPath:@"memberName"];
    [member setValue:extensionDic forKeyPath:@"extension"];
    member.agentNickName = _message.fromUser.nicename;
    return member;
}

- (void)getVisitorScreenshotCompletion:(void (^)(NSString * _Nonnull, HDError * _Nonnull))aCompletion{
    
    self.Completion = aCompletion;
   
    NSString * cachesPath = [NSString stringWithFormat:@"%@/filename.png",[HDSanBoxFileManager cachesDir]] ;

    [self.agoraKit takeSnapshot:[HDVECAgoraCallManager shareInstance].keyCenter.agoraChannel uid:_visitorUid filePath:cachesPath];
    
}

#pragma mark - <AgoraRtcEngineDelegate>
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    
    _visitorUid = uid;
    NSLog(@"join Member  uid---- %lu ",(unsigned long)uid);
    HDVECAgoraCallMember *mem = [self getHDAgoraCallMember:uid];
    @synchronized(self.members){
        BOOL isNeedAdd = YES;
        for ( HDVECAgoraCallMember *member in self.members) {
            if ([member.memberName isEqualToString:mem.memberName]) {
                isNeedAdd = NO;
                break;
            }
        }
        if (isNeedAdd) {
    
            [self.members addObject: mem];
    
        }
    };
    if([self.roomDelegate respondsToSelector:@selector(onMemberJoin:)]){
        [self.roomDelegate onMemberJoin:mem];
    }

}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine remoteVideoStateChangedOfUid:(NSUInteger)uid state:(AgoraVideoRemoteState)state reason:(AgoraVideoRemoteStateReason)reason elapsed:(NSInteger)elapsed
{
    NSLog(@"remoteVideoStateChangedOfUid %@ %@ %@", @(uid), @(state), @(reason));
}
- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine firstLocalVideoFrameWithSize:(CGSize)size elapsed:(NSInteger)elapsed{
    
    NSLog(@"remoteVideoStateChangedOfUid");
    
}



/// Reports an error during SDK runtime.
/// @param engine - RTC engine instance
/// @param errorCode - see complete list on this page
///         https://docs.agora.io/en/Video/API%20Reference/oc/Constants/AgoraErrorCode.html
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurError:(AgoraErrorCode)errorCode {
    HDError *dhError = [[HDError alloc] initWithDescription:@"Occur error " code:(HDErrorCode)errorCode];
    !self.Completion?:self.Completion(nil,dhError);

}


/// 远端用户（通信场景）/主播（直播场景）离开当前频道回调
/// @param engine engine
/// @param uid 离线的用户 ID。
/// @param reason 离线原因
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason{
  
    HDVECAgoraCallMember *mem = [self getHDAgoraCallMember:uid];
   
    HDVECAgoraCallMember *needRemove = nil;
    @synchronized(_members){
        for (HDVECAgoraCallMember *_member in self.members) {
            if ([_member.memberName isEqualToString:mem.memberName]) {
                needRemove = _member;
            }
        }
        if (needRemove) {
            [self.members removeObject:needRemove];
        }
    };
    
    [HDLog logI:@"================vec1.2=====didOfflineOfUid _thirdAgentUid= %lu",(unsigned long)uid];
    //如果房间里边人 都么有了 就发送通知 关闭。如果有人 就不关闭
//  [self agentHangUpCall:[HDAgoraCallManager shareInstance].keyCenter.callid];
   
    //通知代理
    if([self.roomDelegate respondsToSelector:@selector(onMemberExit:)]){
        [self.roomDelegate onMemberExit:mem];
    }
  
    
}
- (void)rtcEngine:(AgoraRtcEngineKit *)engine virtualBackgroundSourceEnabled:(BOOL)enabled reason:(AgoraVirtualBackgroundSourceStateReason)reason{
    
    NSLog(@"virtualBackgroundSourceEnabled = %d  &#xe650; = reason=%luu",enabled,(unsigned long)reason);
    
}

/// 远端用户音频静音回调
/// @param engine AgoraRtcEngineKit
/// @param muted muted
/// @param uid  uid
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didAudioMuted:(BOOL)muted byUid:(NSUInteger)uid{
    
    
    //通知代理
    if([self.roomDelegate respondsToSelector:@selector(onCalldidAudioMuted:byUid:)]){
        
        [self.roomDelegate onCalldidAudioMuted:muted byUid:uid];
    }
}
/// 远端用户关闭视频回调
/// @param engine AgoraRtcEngineKit
/// @param muted muted
/// @param uid  uid
- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid{
    //通知代理
    if([self.roomDelegate respondsToSelector:@selector(onCalldidVideoMuted:byUid:)]){
        
        [self.roomDelegate onCalldidVideoMuted:muted byUid:uid];
    }
    
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine snapshotTaken:(NSString *)channel uid:(NSUInteger)uid filePath:(NSString *)filePath width:(NSInteger)width height:(NSInteger)height errCode:(NSInteger)errCode{
    
    
    NSLog(@"====%@",filePath);
    
    // 图片上传
        
    NSData * imageData = [NSData dataWithContentsOfFile:filePath];
    
//    UIImage * img1 = [UIImage imageWithData:data];
//
//
//    UIImage * img = [UIImage imageWithContentsOfFile:filePath];
//
//    NSData  * imageData = UIImagePNGRepresentation(img);
    
    [[HLCallManager sharedInstance] asyncUploadScreenshotImageWithFile:imageData completion:^(NSString * _Nonnull url, HDError * _Nonnull error) {
        
        if (error==nil) {
            
        
            
            !self.Completion?:self.Completion(url,error);
            
        }else{
            
            
            
        }
        NSLog(@"======%@",url);
       
        
    }];
}


#pragma mark - AgoraRtcEngineKit 屏幕分享 相关
/// 保持动态数据 给其他app 进程通信
/// @param keyCenter 对象参数
- (void)saveAppKeyCenter:(HDKeyCenter *)keyCenter{

    self.userDefaults =[[NSUserDefaults alloc] initWithSuiteName:kAppGroup];
   
    
    [self.userDefaults setObject:keyCenter.agoraAppid forKey:kSaveAgoraAppID];
    
    [self.userDefaults setObject:keyCenter.agoraToken forKey:kSaveAgoraToken];
    
    [self.userDefaults setObject:keyCenter.agoraChannel forKey:kSaveAgoraChannel];
    
    [self.userDefaults setObject:[NSString stringWithFormat:@"%@",keyCenter.callid] forKey:kSaveAgoraCallId];
    
    [self.userDefaults setObject:[NSString stringWithFormat:@"%@",keyCenter.agoraUid] forKey:kSaveAgoraShareUID];
    
//
   
}

- (HDKeyCenter *)getAppKeyCenter{
    HDKeyCenter * keycenter= [[HDKeyCenter  alloc] init];
    keycenter.agoraAppid = [[HDVECAgoraCallManager shareInstance].userDefaults valueForKey:kSaveAgoraAppID];
    keycenter.agoraAppid = [[HDVECAgoraCallManager shareInstance].userDefaults valueForKey:kSaveAgoraAppID];
    keycenter.agoraAppid = [[HDVECAgoraCallManager shareInstance].userDefaults valueForKey:kSaveAgoraAppID];
    keycenter.agoraAppid = [[HDVECAgoraCallManager shareInstance].userDefaults valueForKey:kSaveAgoraAppID];
    return  keycenter;
}

- (BOOL)isScreenShareUid:(NSUInteger)uid{
    HDKeyCenter * shareKey = [self getAppKeyCenter];
    if (shareKey.shareUid.length > 0) {
        if (uid == [shareKey.shareUid integerValue]) {
            return  YES;
        }
        return  NO;
    }
//    return uid >= SCREEN_SHARE_UID_MIN && uid <= SCREEN_SHARE_UID_MAX;
    return YES;
}

- (void)initSettingWithCompletion:(void(^)(id  responseObject, HDError *error))aCompletion {
    kWeakSelf
    [[HDClient sharedClient].callManager hd_getInitVECSettingWithCompletion:^(id  responseObject, HDError *error) {
    
        if (!error && [responseObject isKindOfClass:[NSDictionary class]] ) {
            
            NSDictionary * dic= responseObject;
            if ([[dic allKeys] containsObject:@"status"] && [[dic valueForKey:@"status"] isEqualToString:@"OK"]) {
           
                NSDictionary * tmp = [dic objectForKey:@"entity"];
                
                NSString *configJson = [tmp objectForKey:@"configJson"];
                NSDictionary *jsonDic = [weakSelf dictWithString:configJson];
                
                
                
            //接口请求成功
        //        UI更新代码
//                HDVideoLayoutModel * model = [weakSelf setModel:jsonDic];
//                
//                [HDAgoraCallManager shareInstance].layoutModel = model;
                
               
            }
        }
        if (aCompletion) {
            aCompletion(responseObject,nil);
        }
    }];
}
- (NSDictionary *)dictWithString:(NSString *)string {
    if (string && 0 != string.length) {
        NSError *error;
        NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            NSLog(@"==%@",error);
            return nil;
        }
        return jsonDict;
    }
    
    return nil;
}
//- (HDVideoLayoutModel *)setModel:(NSDictionary *)dic{
//
//    HDVideoLayoutModel * model = [[HDVideoLayoutModel alloc] init];
//        if ([[dic allKeys] containsObject:@"functionSettings"]) {
//            NSDictionary *functionSettings = [dic valueForKey:@"functionSettings"];
//            model.visitorCameraOff = [[functionSettings valueForKey:@"visitorCameraOff"] integerValue];
//            model.skipWaitingPage = [[functionSettings valueForKey:@"skipWaitingPage"] integerValue];
//        }
//        if ([[dic allKeys] containsObject:@"styleSettings"]) {
//            NSDictionary *styleSettings = [dic valueForKey:@"styleSettings"];
//            model.waitingPrompt = [styleSettings valueForKey:@"waitingPrompt"];
//            model.waitingBackgroundPic = [styleSettings valueForKey:@"waitingBackgroundPic"];
//            model.callingPrompt = [styleSettings valueForKey:@"callingPrompt"];
//            model.callingBackgroundPic = [styleSettings valueForKey:@"callingBackgroundPic"];
//            model.queuingPrompt = [styleSettings valueForKey:@"queuingPrompt"];
//            model.queuingBackgroundPic = [styleSettings valueForKey:@"queuingBackgroundPic"];
//            model.endingPrompt = [styleSettings valueForKey:@"endingPrompt"];
//            model.endingBackgroundPic = [styleSettings valueForKey:@"endingBackgroundPic"];
//        }
//
//    return model;
//}

/// 获取会话全部视频通话详情
- (void)getAllVideoDetailsSession:(NSString *)sessionId completion:(void(^)(id responseObject,HDError *error))aCompletion{
    
    [[HLCallManager sharedInstance] getAllVideoDetailsSession:sessionId completion:aCompletion];
    
}
- (AgoraScreenCaptureParameters2 *)screenCaptureParams{
    
    if (!_screenCaptureParams) {
        _screenCaptureParams = [[AgoraScreenCaptureParameters2 alloc] init];
        _screenCaptureParams.captureAudio = YES;
        _screenCaptureParams.captureVideo = YES;
       
       AgoraScreenVideoParameters *videoParams = [[AgoraScreenVideoParameters alloc] init];
       videoParams.dimensions = CGSizeMake(1920, 1080);
        videoParams.frameRate = 30;
      _screenCaptureParams.videoParams = videoParams;
    
    }
    
    return _screenCaptureParams;
}
@end