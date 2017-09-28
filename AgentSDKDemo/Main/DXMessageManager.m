//
//  DXMessageManager.m
//  EMCSApp
//
//  Created by EaseMob on 15/4/20.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "DXMessageManager.h"

#import <AudioToolbox/AudioToolbox.h>
#import "UIAlertView+AlertBlock.h"
#import "HomeViewController.h"
#define kPollingInterval 31.f
#define kDefaultPlaySoundInterval 3.0f
#define kDefaultInterval 0.5f


@interface XHSoundManager : NSObject
{
    SystemSoundID refreshSound;
}

@end

@implementation XHSoundManager

+ (instancetype)sharedInstance {
    static XHSoundManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XHSoundManager alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"/System/Library/Audio/UISounds/%@.%@",@"sms-received1",@"caf"]];
        if (!TARGET_IPHONE_SIMULATOR) {
             AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url) , &refreshSound);
        }
    }
    return self;
}

- (void)playRefreshSound {
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(refreshSound);
}

@end

static DXMessageManager *manager = nil;
static NSInteger httpStatus;

@implementation DXMessageManager 
{
    dispatch_queue_t pollingQueue;
    void *pollingQueueTag;
    int state;
    dispatch_source_t pollingTimer;
    NSTimeInterval lastSendReceiveTime;
    NSURLSessionDataTask *_task;
    BOOL _isNewInstanceLogin;
    NSDate *_lastPlaySoundDate;
    NSString *_curSessionId;
    dispatch_queue_t message_queue;
    NSMutableArray *_messageArray;
}

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DXMessageManager alloc] init];
        httpStatus = -1;
    });
    
    return manager;
}

- (id)init
{
    if ((self = [super init]))
    {
        pollingQueue = dispatch_queue_create("pollingQueue", NULL);
        pollingQueueTag = &pollingQueueTag;
        dispatch_queue_set_specific(pollingQueue, pollingQueueTag, pollingQueueTag, NULL);
        state = DX_DISCONNECTED;
        [self registerEaseMobNotification];
        message_queue = dispatch_queue_create("kefu.easemob.message.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - registerEaseMobNotification
- (void)registerEaseMobNotification{
    [self unRegisterEaseMobNotification];
    // 将self 添加到SDK回调中，以便本类可以收到SDK回调
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
}

- (void)unRegisterEaseMobNotification{
    [[EMClient sharedClient].chatManager removeDelegate:self];
}


- (BOOL)currentState
{
    return [[EMClient sharedClient] isConnected];
}

- (void)setCurSessionId:(NSString*)curSessionId
{
    _curSessionId = curSessionId;
}

- (NSString*)curSessionId
{
    return _curSessionId;
}



@end
