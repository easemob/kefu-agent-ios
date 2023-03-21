//
//  HDScreeShareManager.m
//  AgentSDKDemo
//
//  Created by easemob on 2023/3/8.
//  Copyright © 2023 环信. All rights reserved.
//

#import "HDVECScreeShareManager.h"
#define kScreenShareExtensionBundleId @"com.easemob.kefuapp.AgentSDKDemoAppstoreExtension"
static NSString * _Nonnull kUserDefaultState = @"KEFU_AGENT_KEY_BXL_DEFAULT_STATE"; // 接收屏幕共享(开始/结束 状态)监听的Key
static NSString * _Nonnull kVECAppGroup = @"group.com.easemob.kefuapp";
static void *KVOContext = &KVOContext;

@implementation HDVECScreeShareManager
static HDVECScreeShareManager *shareManager = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[HDVECScreeShareManager alloc] init];
    });
    return shareManager;
}
/// 初始化屏幕分享view
- (void)vec_initBroadPickerView{
    if (@available(iOS 12.0, *)) {
        _broadPickerView = [[RPSystemBroadcastPickerView alloc] init];
        _broadPickerView.preferredExtension = kScreenShareExtensionBundleId;
        _broadPickerView.showsMicrophoneButton = NO;
        _broadPickerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        // 设置appgroup 相关 保证app进程间正常通信
        [self vec_setupUserDefaults];
        for (UIView *view in _broadPickerView.subviews)
        {
            if ([view isKindOfClass:[UIButton class]])
            {
                //调起录像方法，UIControlEventTouchUpInside的方法看其他文章用的是UIControlEventTouchDown，
                //我使用时用UIControlEventTouchUpInside用好使，看个人情况决定
                [(UIButton*)view sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
      
    } else {
        // Fallback on earlier versions
        [MBProgressHUD  dismissInfo:NSLocalizedString(@"屏幕共享不能使用", "leaveMessage.leavemsg.uploadattachment.failed")  withWindow:[UIApplication sharedApplication].keyWindow];
    }
}
- (void)vec_startScreenCapture{
    
    //在加入频道后调用 startScreenCapture，然后调用 updateChannelWithMediaOptions 更新频道媒体选项并设置 publishScreenCaptureVideo 为 true，即可开始屏幕共享。
    int success=  [[HDAgoraCallManager shareInstance].agoraKit startScreenCapture:[HDAgoraCallManager shareInstance].screenCaptureParams];
    
    NSLog(@"====success=%d",success);
    AgoraRtcChannelMediaOptions * option = [AgoraRtcChannelMediaOptions new];
    option.publishScreenCaptureVideo = YES;
    //这个属性必须设置 要不 屏幕共享的流推不出去
    option.publishCameraTrack = NO;
   
    int updateSuccess=  [[HDAgoraCallManager shareInstance].agoraKit updateChannelWithMediaOptions:option];
    NSLog(@"====updateSuccess=%d",updateSuccess);
    // 发送通知 屏幕共享开始了
    [[NSNotificationCenter defaultCenter] postNotificationName:HDVEC_SCREENSHARE_STATRT object:nil];
}

- (void)vec_stopScreenCapture{

    int success=  [[HDAgoraCallManager shareInstance].agoraKit stopScreenCapture];
    NSLog(@"====success=%d",success);
    AgoraRtcChannelMediaOptions * option = [AgoraRtcChannelMediaOptions new];
    option.publishScreenCaptureVideo = NO;
    //这个属性必须设置 要不 屏幕共享的流推不出去
    option.publishCameraTrack = YES;

    int updateSuccess=  [[HDAgoraCallManager shareInstance].agoraKit updateChannelWithMediaOptions:option];

    NSLog(@"====updateSuccess=%d",updateSuccess);
    
    // 发送通知 屏幕共享停止了
    [[NSNotificationCenter defaultCenter] postNotificationName:HDVEC_SCREENSHARE_STOP object:nil];
    
}

#pragma mark - 进程间通信-CFNotificationCenterGetDarwinNotifyCenter 使用之前，需要为container app与extension app设置 App Group，这样才能接收到彼此发送的进程间通知。
// 录屏直播 主App和宿主App数据共享，通信功能实现 如果我们要将开始、暂停、结束这些事件以消息的形式发送到宿主App中，需要使用CFNotificationCenterGetDarwinNotifyCenter。
- (void)vec_setupUserDefaults{
    
    self.userDefaults =[[NSUserDefaults alloc] initWithSuiteName:kVECAppGroup];
    // 通过UserDefaults建立数据通道，接收Extension传递来的视频帧
    [self.userDefaults setObject:@{@"state":@"x"} forKey:kUserDefaultState];//给状态一个默认值
    [self.userDefaults addObserver:self forKeyPath:kUserDefaultState options:NSKeyValueObservingOptionNew context:KVOContext];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:kUserDefaultState]) {
        NSDictionary *string = change[NSKeyValueChangeNewKey];
        if ([string[@"state"] isEqual:@"broadcastStarted"]) {
            //开启 RTC：外部视频输入通道，开始推送屏幕流（configLocalScreenPublish）
            NSLog(@"== 屏幕分享开始=====%@",string);
            // 开启屏幕共享
            [self vec_startScreenCapture];
        }
        if ([string[@"state"] isEqual:@"broadcastFinished"]) {
            //关闭 RTC：外部视频输入通道，停止推送屏幕流
            NSLog(@"== 屏幕分享停止=====%@",string);
            [self vec_stopScreenCapture];
        }
        return;
    }
}

@end