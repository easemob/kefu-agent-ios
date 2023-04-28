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

@interface HDVECAgoraCallManager () <AgoraRtcEngineDelegate>
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
@property (nonatomic, copy) void (^Completion)(id, HDError *)  ;


@end
@implementation HDVECAgoraCallManager
{
    BOOL _onCalling; //正在通话
    NSMutableDictionary *_cacheStreams; //没有点击接受的时候缓存的stream
    NSMutableArray *_waitingQueue;  //正在加入会话
    NSString * _pubViewId;
    dispatch_queue_t _callQueue;
    
    HDVECTicketModel *_agentTicketModel;
    HDVECTicketModel *_visitorTicketModel;
    HDVECTicketModel *_shareScreenTicketModel;
    
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
    }
    return self;
}

- (void)vec_SetVECAgentStatus:(HDAgentServiceType)type completion:(void (^)(id responseObject, HDError * _Nonnull))completion{
    
    switch (type) {
        case HDAgentServiceType_VEC:
            
            [[HDVECManager sharedInstance] vec_updateAgentStatus:HDVECAgentLoginStatusIdle completion:completion];
            
            break;
            
        default:
            break;
    }
}
- (void)vec_GetVECAgentStatusCompletion:(void (^)(id _Nonnull, HDError * _Nonnull))completion{
    
    [[HDVECManager sharedInstance] vec_getAgentStatusCompletion:completion];
    
}

- (void)setCallOptions:(HDVECAgoraCallOptions *)aOptions{
    _options = aOptions;
}
- (HDVECAgoraCallOptions *)getCallOptions{
    
    return _options;
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
        // set video configuration
        float size = _options.dimension.width;
        AgoraVideoEncoderConfiguration *configuration =[[AgoraVideoEncoderConfiguration alloc] initWithSize: (size>0 ? _options.dimension :AgoraVideoDimension480x480 ) frameRate:AgoraVideoFrameRateFps24 bitrate:_options.bitrate ? _options.bitrate :AgoraVideoBitrateStandard orientationMode:AgoraVideoOutputOrientationModeAdaptative mirrorMode:AgoraVideoMirrorModeDisabled];
    
        [_agoraKit setVideoEncoderConfiguration:configuration];
    
    }
    return _agoraKit;
}
#pragma mark - 设置相关
- (void)setEnableVirtualBackground:(BOOL)enable{
    
    AgoraVirtualBackgroundSource *backgroundSource = [[AgoraVirtualBackgroundSource alloc] init];
    backgroundSource.backgroundSourceType = AgoraVirtualBackgroundColor;

    AgoraSegmentationProperty  * seg = [[AgoraSegmentationProperty alloc] init];
    seg.modelType = SegModelAgoraAi;
    [self.agoraKit enableVirtualBackground:enable backData:backgroundSource segData:seg];
    
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
    [self vec_endRecord];
    [HDAppManager shareInstance].isAnswerView = NO;
}

- (void)vec_endCall{
    //1、停止录制
    [self vec_endRecord];
    //2、发送挂断消息
    [self vec_endSendMessage];
    //3、声网 离开房间
    [self.agoraKit leaveChannel:nil];
    //4、清理设置的状态
    [self vec_endClearState];
    //5、销毁引擎
    [self destroy];

//    // 发送测试 通知显示 视频记录列表
//    //发通知加入房间
//    [[NSNotificationCenter defaultCenter] postNotificationName:HDCALL_KefuRtcCallRinging_VEC_sessionhistory object:nil];
}

///  结束录制接口
- (void)vec_endRecord{
    
    [[HDClient sharedClient].vecCallManager vec_stoptAgoraRtcRecodWithRtcSessionId:_ringingCallModel.rtcSessionId withAgentId:_ringingCallModel.agentUserId completion:^(id  _Nonnull responseObject, HDError * _Nonnull error) {
        NSLog(@"======%@",responseObject);
    }];
}
/// 发送挂断视频消息
- (void)vec_endSendMessage{
    
   HDMessage * message  =  [self vec_sendMessageVideoPlaybackSessionId:_ringingCallModel.rtcSessionId withToUser:_ringingCallModel.visitorUserId withVisitorName:_ringingCallModel.visitorUserName];
    [[HDClient sharedClient].vecCallManager vec_asyncSendMessageWithMessageModel:message completion:^(HDMessage * _Nonnull message, HDError * _Nonnull error) {
        
        if (error==nil) {
            
            NSLog(@"======发送消息成功");
        }
    }];
}

/// 清理通话中设置的状态
-(void)vec_endClearState{
    [_members removeAllObjects];
    _isSetupLocalVideo = NO;
    _onCalling = NO;
    [HDAppManager shareInstance].isAnswerView = NO;
    
}
- (void)destroy{
    _onCalling = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        //该方法为同步调用，需要等待 AgoraRtcEngineKit 实例资源释放后才能执行其他操作，所以我们建议在子线程中调用该方法，避免主线程阻塞。此外，我们不建议 在 SDK 的回调中调用 destroy，否则由于 SDK 要等待回调返回才能回收相关的对象资源，会造成死锁。
        [AgoraRtcEngineKit destroy];
        self.agoraKit = nil;
    });
}

- (int)startPreview{
    return [self.agoraKit startPreview];
}
- (int)stopPreview{
    
    return [self.agoraKit stopPreview];
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
- (void)vec_createTicketDidReceiveAgoraInit {
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
    HDVECTicketModel * model =[self vec_getAgentTicketCallOptions];
    if (model) {
        key.agoraToken = model.token;
        key.agoraAppid = model.appId;
        key.agoraChannel = model.channel;
        key.agoraUid = [NSString stringWithFormat:@"%lu",(unsigned long)model.uid];
        key.callid =   [NSString stringWithFormat:@"%lu",(unsigned long)model.callId] ;
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

//解析获取的通行证接口的数据
- (BOOL)vec_setAgoraTicketModel:(NSDictionary *)dic{
    
    if (dic&&[dic isKindOfClass:[NSDictionary class]] &&dic.count >0) {
        
        if ([[dic allKeys] containsObject:@"entity"]) {

            NSDictionary * entity = [dic objectForKey:@"entity"];
            
            if ([[entity allKeys] containsObject:@"agentTicket"]) {
               
                _agentTicketModel = [HDVECTicketModel yy_modelWithDictionary:[entity objectForKey:@"agentTicket"]];
                
            }
            if ([[entity allKeys] containsObject:@"shareScreenTicket"]) {
                
                _shareScreenTicketModel = [HDVECTicketModel yy_modelWithDictionary:[entity objectForKey:@"shareScreenTicket"]];
            }
            if ([[entity allKeys] containsObject:@"visitorTicket"]) {
                
                _visitorTicketModel = [HDVECTicketModel yy_modelWithDictionary:[entity objectForKey:@"visitorTicket"]];
            }
        }
    }
    if (_agentTicketModel) {
        return YES;
    
    }else{
        return NO;
    }
}

- (HDVECTicketModel *)vec_getAgentTicketCallOptions{
    
    if (_agentTicketModel) {
        
        return _agentTicketModel;
    }
    
    return nil;

}
- (HDVECTicketModel *)vec_getVisitorTicketCallOptions{
    
    
    if (_visitorTicketModel) {
        
        return _visitorTicketModel;
    }
    
    return nil;
    
}

- (HDVECTicketModel *)vec_getShareScreenTicketCallOptions{
    
    
    if (_shareScreenTicketModel) {
        
        return _shareScreenTicketModel;
    }
    
    return nil;
    
}

- (NSDictionary *)vec_getSendVisitorTicketWithVisitorNickname:(NSString *)nickName withVisitorTrueName:(NSString *)trueName{
    
//    {
//        "msg": "邀请你进行实时视频",
//        "type": "cmd",
//        "ext": {
//            "msgtype": {
//                "sendVisitorTicket": {
//                    "msg": "邀请你进行实时视频",
//                    "nickname": "Admin",
//                    "ticket": {
//                        "callId": 16396,
//                        "uid": 5313,
//                        "token": "0060e400b86d6ac439db7533aceace13cadIACOL8c/nGfl8RT5gkff6Ue7qPgnBP3xPYBaJ/UhuikUBmtSgiri6hG5IgAjGRDCj6qyYgQAAQCPqrJiAgCPqrJiAwCPqrJiBACPqrJi",
//                        "appId": "0e400b86d6ac439db7533aceace13cad",
//                        "channel": "a51135b6-5196-48c2-ba1e-0f7f2fc99d19",
//                        "niceName": "webim-visitor-GQTRVB44KR6KHWHGR2QT123",
//                        "trueName": null,
//                        "agentTicket": {
//                            "callId": 16396,
//                            "uid": 55,
//                            "token": "0060e400b86d6ac439db7533aceace13cadIAAGqIcyMItnRWmwj0ZQrNw02tt0esDou7SfTAM7ovdmcWtSgipqFFu1IgBzH5fAj6qyYgQAAQCPqrJiAgCPqrJiAwCPqrJiBACPqrJi",
//                            "appId": "0e400b86d6ac439db7533aceace13cad",
//                            "channel": "a51135b6-5196-48c2-ba1e-0f7f2fc99d19",
//                            "niceName": "Admin",
//                            "trueName": "admin"
//                        },
//    "shareTicket": {
    //                            "callId": 16396,
    //                            "uid": 55,
    //                            "token": "0060e400b86d6ac439db7533aceace13cadIAAGqIcyMItnRWmwj0ZQrNw02tt0esDou7SfTAM7ovdmcWtSgipqFFu1IgBzH5fAj6qyYgQAAQCPqrJiAgCPqrJiAwCPqrJiBACPqrJi",
    //                            "appId": "0e400b86d6ac439db7533aceace13cad",
    //                            "channel": "a51135b6-5196-48c2-ba1e-0f7f2fc99d19",
    //                            "niceName": "Admin",
    //                            "trueName": "admin"
    //                        },
//                        "isThirdAgent": false
//                    }
//                }
//            }
//        }
//    }
    
    if (!_visitorTicketModel) {
        
        return nil;
    }

    NSDictionary *agentTicketDic = [self dictionaryWithJsonString:_agentTicketModel.yy_modelToJSONString];
    
    NSDictionary *_visitorTicketDic = [self dictionaryWithJsonString:_visitorTicketModel.yy_modelToJSONString];
    
    NSMutableDictionary * ticket =[NSMutableDictionary dictionaryWithDictionary:_visitorTicketDic];;
    [ticket hd_setValue:_visitorTicketModel.niceName forKey:@"niceName"];
    [ticket hd_setValue:_visitorTicketModel.trueName forKey:@"trueName"];
    [ticket hd_setValue:agentTicketDic forKey:@"agentTicket"];
    [ticket hd_setValue:@"false" forKey:@"isThirdAgent"];
                        
    NSMutableDictionary * sendVisitorTicket = [[NSMutableDictionary alloc] init];
    [sendVisitorTicket  hd_setValue:@"邀请你进行实时视频" forKey:@"msg"];
    [sendVisitorTicket  hd_setValue:  [[HDUserManager sharedInstance] getAgentUserModel].username forKey:@"nickname"];
    [sendVisitorTicket  hd_setValue:ticket forKey:@"ticket"];

    NSMutableDictionary * msgtypeDic = [[NSMutableDictionary alloc] init];

    [msgtypeDic hd_setValue:sendVisitorTicket forKey:@"sendVisitorTicket"];
    [msgtypeDic hd_setValue:@"kefurtc" forKey:@"targetSystem"];

    return msgtypeDic;
    
}
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
- (void)vec_sendCmdMessage:(NSDictionary *)msgtypeDic withSessionId:(NSString *)sessionId withToUser:(NSString *)toUser completion:(void (^)(HDMessage * _Nonnull, HDError * _Nonnull))aCompletionBlock{
    
    NSString *willSendText = @"邀请你进行实时视频";
    
    HDCMDMessageBody  *body = [[HDCMDMessageBody alloc] initWithMsg:willSendText];
    
    HDMessage *message = [[HDMessage alloc] initWithSessionId:sessionId to:toUser messageBody:body];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters hd_setValue: msgtypeDic forKey:@"msgtype"];
   
    message.nBody.msgExt = parameters;
    
    
    [[HDClient sharedClient].vecCallManager vec_asyncSendMessageWithMessageModel:message completion:aCompletionBlock];

}
- (HDMessage *)vec_sendMessageVideoPlaybackSessionId:(NSString *)sessionId withToUser:(NSString *)toUser withVisitorName:(NSString *)visitorName {
    
    NSString *willSendText = @"视频通话已结束";
    HDTextMessageBody *body = [[HDTextMessageBody alloc] initWithText:willSendText];
    HDMessage *message = [[HDMessage alloc] initWithSessionId:sessionId to:toUser messageBody:body];
    
    NSDictionary *dic = @{
                          @"type":@"agorartcmedia/video",
                          @"msgtype":@{
                                  @"videoPlayback":@{
                                          @"msg": @"playback",
                                          },
                                  @"targetSystem":@"kefurtc"
                                 
                                  }
                          };

    message.nBody.msgExt = dic;
    [HDLog logI:@"vec_sendMessageVideoPlaybackSessionId=======%@",dic];
    return message;
    
}

/**
 接受视频会话

 @param nickname 传递自己的昵称到对方
 @param completion 完成回调
 */
- (void)vec_acceptCallWithNickname:(NSString *)nickname completion:(void (^)(id, HDError *))completion{
    self.Completion = completion;
    [HDLog logI:@"================vec1.2=====收到坐席回呼cmd消息 acceptCallWithNickname "];
    [self hd_joinChannelByToken:[HDVECAgoraCallManager shareInstance].keyCenter.agoraToken channelId:[HDVECAgoraCallManager shareInstance].keyCenter.agoraChannel info:nil uid:[[HDVECAgoraCallManager shareInstance].keyCenter.agoraUid integerValue] joinSuccess:^(NSString * _Nullable channel, NSUInteger uid, NSInteger elapsed) {
        _onCalling = YES;
        [HDLog logI:@"================vec1.2=====收到坐席回呼cmd消息 joinSuccess channel "];
        self.Completion(nil, nil);
        // 加入房间成功以后  给访客发消息
        [self vec_sendCmdMessage:[self vec_getSendVisitorTicketWithVisitorNickname:_visitorTicketModel.niceName withVisitorTrueName:_visitorTicketModel.trueName] withSessionId:[HDVECAgoraCallManager shareInstance].ringingCallModel.rtcSessionId withToUser:[HDVECAgoraCallManager shareInstance].ringingCallModel.visitorUserId completion:^(HDMessage * _Nonnull message, HDError * _Nonnull error) {
        
            if (error==nil) {
                
                //加入成功以后 开始 录制
                [[HDVECManager sharedInstance] vec_startAgoraRtcRecodWithRtcSessionId:_ringingCallModel.rtcSessionId withAgentId:_ringingCallModel.agentUserId completion:^(id  _Nonnull responseObject, HDError * _Nonnull error) {
                   
                    if (error == nil) {
                        NSLog(@"=======开始录制接口返回成功");
                    }
                }];
            }
        }];
        
    }];

}
- (void)hd_saveShareDeskData:(HDKeyCenter *)keyCenter{
    
    if (keyCenter) {
        
        [self saveAppKeyCenter:[HDVECAgoraCallManager shareInstance].keyCenter];
    }
    
}




- (HDVECRingingCallModel *)vec_parseKefuRtcCallRingingData:(NSDictionary *)dic{
    
    
    if (dic&& [dic isKindOfClass:[NSDictionary class]] && dic.count > 0) {
        
        if ([[dic allKeys] containsObject:@"body"] && [[dic objectForKey:@"body"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary * body = [dic objectForKey:@"body"];
            if ([[body allKeys]containsObject:@"rtcSession"]&& [[body objectForKey:@"rtcSession"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary * rtcSession = [body objectForKey:@"rtcSession"];
                HDVECRingingCallModel * model = [HDVECRingingCallModel yy_modelWithDictionary:rtcSession];
                
                if (model) {
                    
                    return  model;
                }
            }
        }
    }
    
    return  nil;
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
    member.agentNickName = _ringingCallModel.visitorUserNickName;
    return member;
}

- (void)vec_getVisitorScreenshotCompletion:(void (^)(NSString * _Nonnull, HDError * _Nonnull))aCompletion{
    
    self.Completion = aCompletion;
   
    NSString * cachesPath = [NSString stringWithFormat:@"%@/filename.png",[HDSanBoxFileManager cachesDir]] ;
    [self.agoraKit takeSnapshot:_visitorUid filePath:cachesPath];
    
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
    //通知代理
    if([self.roomDelegate respondsToSelector:@selector(onMemberExit:)]){
        [self.roomDelegate onMemberExit:mem];
    }
  
    
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
    
    [[HDOnlineManager sharedInstance] asyncUploadScreenshotImageWithFile:imageData completion:^(NSString * _Nonnull url, HDError * _Nonnull error) {
        
        if (error==nil) {
            
        
            
            !self.Completion?:self.Completion(url,error);
            
        }else{
            
            
            
        }
        NSLog(@"======%@",url);
       
        
    }];
}
- (BOOL)vec_isVisitorCancelInvitationMessage:(NSDictionary *)dic{
    
    if (dic&& [dic isKindOfClass:[NSDictionary class]] && dic.count > 0) {
        
        if ([[dic allKeys] containsObject:@"body"] && [[dic objectForKey:@"body"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary * body = [dic objectForKey:@"body"];
            if ([[body allKeys]containsObject:@"rtcMessage"]&& [[body objectForKey:@"rtcMessage"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary * rtcMessage = [body objectForKey:@"rtcMessage"];
               
                if ([[rtcMessage allKeys] containsObject:@"body"]&& [[rtcMessage objectForKey:@"body"] isKindOfClass:[NSDictionary class]]) {
                    
                    NSDictionary *rtcMessageBody =[rtcMessage objectForKey:@"body"];
                    
                    if ([[rtcMessageBody allKeys] containsObject:@"ext"]&& [[rtcMessageBody objectForKey:@"ext"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *rtcMessageExt =[rtcMessageBody objectForKey:@"ext"];
                        
                        return [HDUtils isVisitorCancelInvitationMessage:rtcMessageExt];
                    }
                }
            }
        }
    }
    
    return NO;
    
}
#pragma mark -------------------------VEC 视频排队 相关 ----------------------------------

/**
   获取视频记录
 Integer pageNum 页码(默认0)
 Integer pageSize 页大小（默认10）
 Integer tenantId 租户ID
 String agentUserId 客服ID
 String visitorUserId 访客ID
 Date createDateFrom 通话创建时间（开始范围条件）2022-05-12 16:30:00
 Date createDateTo 通话创建时间（结束范围条件）2022-05-12 16:30:00
 Date startDateFrom 首次通话接起时间（开始范围条件）2022-05-12 16:30:00
 Date startDateTo 首次通话接起时间（结束范围条件）2022-05-12 16:30:00
 Date stopDateFrom 结束时间（开始范围条件）2022-05-12 16:30:00
 Date stopDateTo 通话结束时间（结束范围条件）2022-05-12 16:30:00
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
                                  completion:(void (^)(id responseObject, HDError *error))completion{
    
    
    [[HDClient sharedClient].vecCallManager vec_getRtcSessionhistoryParameteData:data completion:completion];
    
}

/*  正常通话场景 如果查全部hangUpReason 数组为空 即可
 NORMAL  正常结束（接通后结束）
 RING_GIVE_UP   振铃放弃（指定振铃时间内，访客挂断/离开）
 AGENT_REJECT  客服拒接（振铃过程中客服主动挂断）
 VISITOR_REJECT   访客拒接（振铃过程中访客主动挂断）
 */
- (NSDictionary *)vec_getSessionhistoryParameteData{
    NSString * agentId = [HDClient sharedClient].currentAgentUser.agentId;
    NSString *startTime =  [self dateWithTimeInterval: [self getTime:0 andMinute:0 andSecond:0]];
    NSString *endTime =   [self dateWithTimeInterval:[self getTime:23 andMinute:59 andSecond:59]];
    
    NSArray * state = @[@"Processing",@"Terminal",@"Abort"];
    NSArray * hangUpUserType = @[];
    NSArray * hangUpReason = @[];
    NSArray * queueIds = @[];
    NSArray * originType = @[];
    NSArray * techChannels = @[];
    NSDictionary * dic = @{
        @"pageNum": @0,
        @"pageSize": @1000,
        @"tenantId": [HDClient sharedClient].currentAgentUser.tenantId,
        @"agentUserId": agentId,
//        @"visitorUserId": @"",
        @"createDateFrom": [NSString stringWithFormat:@"%@00:00:00",startTime],
        @"createDateTo": [NSString stringWithFormat:@"%@24:00:00",endTime],
//        @"startDateFrom": @"",
//        @"startDateTo": @"",
//        @"stopDateFrom": @"",
//        @"stopDateTo": @"",
        @"isAgent": @"false",
//        @"sortField": @"createDatetime",// 要么不传这个字段 要么就传上值 否则会有问题
//        @"sortOrder": @"desc",
//        @"rtcSessionId": @"",
//        @"customerName": @"",
//        @"visitorName": @"",
//        @"originType": originType,
//        @"queueIds": queueIds,
//        @"hangUpReason": hangUpReason,
//        @"hangUpUserType": hangUpUserType,
//        @"techChannels":techChannels,
        @"state":state
        
        
    };
    
    return dic;
    
}
- (NSString *)getTime: (NSInteger)hour andMinute:(NSInteger)minute andSecond:(NSInteger)second {
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [greCalendar setTimeZone: timeZone];

    NSDateComponents *dateComponents = [greCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay  fromDate:[NSDate date]];
    //  定义一个NSDateComponents对象，设置一个时间点
    NSDateComponents *dateComponentsForDate = [[NSDateComponents alloc] init];
    [dateComponentsForDate setDay:dateComponents.day];
    [dateComponentsForDate setMonth:dateComponents.month];
    [dateComponentsForDate setYear:dateComponents.year];
    [dateComponentsForDate setHour:hour];
    [dateComponentsForDate setMinute:minute];
    [dateComponentsForDate setSecond:second];

    NSDate *dateFromDateComponentsForDate = [greCalendar dateFromComponents:dateComponentsForDate];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[dateFromDateComponentsForDate timeIntervalSince1970]*1000];
    
    return timeSp;
}
// 时间戳转时间,时间戳为13位是精确到毫秒的，10位精确到秒
-(NSString*)dateWithTimeInterval:(NSString*)timeStr{
    // 传入的时间戳timeStr如果是精确到秒的记得要/1000
    NSTimeInterval timeInterval=[timeStr doubleValue]/1000;
    NSDate*detailDate=[NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter*dateFormatter=[[NSDateFormatter alloc]init];
    // 实例化一个NSDateFormatter对象，设定时间格式，这里可以设置成自己需要的格式
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd "];
    NSString*dateStr=[dateFormatter stringFromDate:detailDate];
    return dateStr;
    
}


// 字符串转时间戳 如：2017-4-10 17:15:10
-(NSString*)getTimeStrWithString:(NSString*)str{
    NSDateFormatter*dateFormatter=[[NSDateFormatter alloc]init];
    // 创建一个时间格式化对象
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //设定时间的格式
    NSDate*tempDate=[dateFormatter dateFromString:str];
    //将字符串转换为时间对象
    NSString*timeStr=[NSString stringWithFormat:@"%ld",(long)[tempDate timeIntervalSince1970]*1000];//字符串转成时间戳,精确到毫秒*1000
    return timeStr;
    
}


/*
 * 获取视频详情
 */

- (void)vec_getCallVideoDetailWithRtcSessionId:(NSString *)rtcSessionId Completion:(void(^)(id responseObject, HDError *error))completion{
    
    
    [[HDClient sharedClient].vecCallManager vec_getCallVideoDetailWithRtcSessionId:rtcSessionId Completion:completion];
    
}


/*
 * 待接入数量 这个接口需要需要轮训获取排队数量
 */
- (void)vec_getSessionsCallWaitWithAgentId:(NSString *)agentId Completion:(void(^)(id responseObject, HDError *error))completion{
    
    [[HDClient sharedClient].vecCallManager vec_getSessionsCallWaitWithAgentId:agentId Completion:completion];
    
    
}
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
 }
 */
- (void)vec_postSessionsCallWaitListParameteData:(NSDictionary*)data Completion:(void(^)(id responseObject, HDError *error))completion{
    
    
    [[HDClient sharedClient].vecCallManager vec_postSessionsCallWaitListParameteData:data Completion:completion];
    
}
- (NSDictionary *)vec_getSessionCallWaitListParameteData{
    
    NSDictionary * dic = @{
        @"page": @0,
        @"size": @20,
        @"mode": @"agent", //  如果要获取管理员下所有的列表 传admin
        @"beginDate": @"",
        @"endDate": @"",
        @"techChannelId": @"",
        @"originType": @"app",
        @"visitorUserId": @""
    };
    return dic;
}
/*
 * 待接入 获取接听 音视频ticket 通行证
 */
- (void)vec_getSessionsCallWaitTicketWithAgentId:(NSString *)agentId withRtcSessionId:(NSString *)rtcSessionId Completion:(void(^)(id responseObject, HDError *error))completion{
    
    [[HDClient sharedClient].vecCallManager vec_getSessionsCallWaitTicketWithAgentId:agentId withRtcSessionId:rtcSessionId Completion:completion];
}

/*
 * 拒接待接入通话
 */
- (void)vec_postSessionsCallWaitRejectWithAgentId:(NSString *)agentId withRtcSessionId:(NSString *)rtcSessionId Completion:(void(^)(id responseObject, HDError *error))completion{
    
    
    [[HDClient sharedClient].vecCallManager  vec_postSessionsCallWaitRejectWithAgentId:agentId withRtcSessionId:agentId Completion:completion];
    
}

#pragma mark -------------------------VEC 视频排队 相关 end ----------------------------------

#pragma mark - AgoraRtcEngineKit 屏幕分享 相关
/// 保持动态数据 给其他app 进程通信
/// @param keyCenter 对象参数
- (void)saveAppKeyCenter:(HDKeyCenter *)keyCenter{

    self.userDefaults =[[NSUserDefaults alloc] initWithSuiteName:kVECAppGroup];
   
    
    [self.userDefaults setObject:keyCenter.agoraAppid forKey:kSaveAgoraAppID];
    
    [self.userDefaults setObject:keyCenter.agoraToken forKey:kSaveAgoraToken];
    
    [self.userDefaults setObject:keyCenter.agoraChannel forKey:kSaveAgoraChannel];
    
    [self.userDefaults setObject:[NSString stringWithFormat:@"%@",keyCenter.callid] forKey:kSaveAgoraCallId];
    
    [self.userDefaults setObject:[NSString stringWithFormat:@"%@",keyCenter.agoraUid] forKey:kSaveAgoraShareUID];
    
//
   
}

/// 开启屏幕共享
- (void)vec_startScreenCapture{
    //在加入频道后调用 startScreenCapture，然后调用 updateChannelWithMediaOptions 更新频道媒体选项并设置 publishScreenCaptureVideo 为 true，即可开始屏幕共享。
    int success=  [self.agoraKit startScreenCapture:[HDVECAgoraCallManager shareInstance].screenCaptureParams];
    
    NSLog(@"====success=%d",success);
    AgoraRtcChannelMediaOptions * option = [AgoraRtcChannelMediaOptions new];
    option.publishScreenCaptureVideo = YES;
    //这个属性必须设置 要不 屏幕共享的流推不出去
    option.publishCameraTrack = NO;
   
    int updateSuccess=  [self.agoraKit updateChannelWithMediaOptions:option];
    NSLog(@"====updateSuccess=%d",updateSuccess);
    
    
}

/// 关闭屏幕共享
- (void)vec_stopScreenCapture{
    int success=  [self.agoraKit stopScreenCapture];
    NSLog(@"====success=%d",success);
    AgoraRtcChannelMediaOptions * option = [AgoraRtcChannelMediaOptions new];
    option.publishScreenCaptureVideo = NO;
    //这个属性必须设置 要不 屏幕共享的流推不出去
    option.publishCameraTrack = YES;

    int updateSuccess=  [[HDVECAgoraCallManager shareInstance].agoraKit updateChannelWithMediaOptions:option];

    NSLog(@"====updateSuccess=%d",updateSuccess);
    
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
    
    [[HDOnlineManager sharedInstance] getAllVideoDetailsSession:sessionId completion:aCompletion];
    
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
