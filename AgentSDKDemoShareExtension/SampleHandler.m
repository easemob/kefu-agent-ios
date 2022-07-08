//
//  SampleHandler.m
//  AgentSDKDemoShareExtension
//
//  Created by houli on 2022/7/4.
//  Copyright © 2022 环信. All rights reserved.
//
#import "SampleHandler.h"
#import <AgoraReplayKitExtension/AgoraReplayKitExt.h>
 #import <sys/time.h>
static NSString * _Nonnull kAppGroup = @"group.com.easemob.enterprise.demo.kefuapp";
static NSString * _Nonnull kUserDefaultState = @"KEY_BXL_DEFAULT_STATE"; // 接收屏幕共享(开始/结束 状态)监听的Key
 @interface SampleHandler ()<AgoraReplayKitExtDelegate>
@property (nonatomic, strong) NSUserDefaults *userDefaults;
 @end


@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    [[AgoraReplayKitExt shareInstance] start:self];
    

}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
    NSLog(@"broadcastPaused");
    [[AgoraReplayKitExt shareInstance] pause];
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
    NSLog(@"broadcastResumed");
    [[AgoraReplayKitExt shareInstance] resume];

}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    NSLog(@"broadcastFinished");
    [[AgoraReplayKitExt shareInstance] stop];
    [self.userDefaults setObject:@{@"state":@"停止"} forKey:kUserDefaultState];//结束字段
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    [[AgoraReplayKitExt shareInstance] pushSampleBuffer:sampleBuffer withType:sampleBufferType];
}

#pragma mark - AgoraReplayKitExtDelegate

- (void)broadcastFinished:(AgoraReplayKitExt *_Nonnull)broadcast reason:(AgoraReplayKitExtReason)reason {
    switch (reason) {
        case AgoraReplayKitExtReasonInitiativeStop:
            {
//                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Host app stop srceen capture"};
//                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:userInfo];
//                [self finishBroadcastWithError:error];
                NSLog(@"AgoraReplayKitExtReasonInitiativeStop");
            }
            break;
        case AgoraReplayKitExtReasonConnectFail:
            {
//                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Connect host app fail need startScreenCapture in host app"};
//                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:userInfo];
//                [self finishBroadcastWithError:error];
                NSLog(@"AgoraReplayKitExReasonConnectFail");
            }
            break;

        case AgoraReplayKitExtReasonDisconnect:
            {
//                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"disconnect with host app"};
//                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:userInfo];
//                [self finishBroadcastWithError:error];
                NSLog(@"AgoraReplayKitExReasonDisconnect");
            }
            break;
        default:
            break;
    }
}
@end
