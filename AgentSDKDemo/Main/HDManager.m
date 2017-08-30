//
//  HDManager.m
//  AgentSDKDemo
//
//  Created by afanda on 4/20/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "HDManager.h"
#import "AppDelegate.h"


@interface HDManager () <HDChatManagerDelegate>

@end
static const CGFloat kDefaultPlaySoundInterval = 3.0;
@implementation HDManager
static HDManager *_manager = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[HDManager alloc] init];
    });
    return _manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)showMainViewController {
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate showMainViewController];
}

- (void)showLoginViewController {
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate showLoginViewController];
     [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

#pragma mark - 本地通知

- (void)registerLocalNoti {
    if ([HDClient sharedClient].chatManager == nil) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(0.8*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self registerLocalNoti];
        });
    } else {
        [[HDClient sharedClient].chatManager removeDelegate:self];
        [[HDClient sharedClient].chatManager addDelegate:self ];
    }
}


- (void)messagesDidReceive:(NSArray<MessageModel *> *)aMessages {
    for (MessageModel *message in aMessages) {
        BOOL needShowLocalNoti = YES;
        if (needShowLocalNoti) {
            UIApplicationState state = [[UIApplication sharedApplication] applicationState];
            switch (state) {
                case UIApplicationStateBackground:
                {
                    [self showNotificationWithMessage:@"您有一条新消息" message:message];
                    break;
                }
                default:
                    [self playSoundAndVibration];
                    break;
            }
        }
    }
}

- (void)playSoundAndVibration{
    

}


- (void)showNotificationWithMessage:(NSString *)message message:(MessageModel *)msgModel;
{
    NSInteger PreviousNum = [UIApplication sharedApplication].applicationIconBadgeNumber;
    [UIApplication sharedApplication].applicationIconBadgeNumber = ++PreviousNum;
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    notification.alertBody = message;
    notification.alertAction = NSLocalizedString(@"open", @"Open");
    notification.timeZone = [NSTimeZone defaultTimeZone];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
    } else {
        notification.soundName = UILocalNotificationDefaultSoundName;
        self.lastPlaySoundDate = [NSDate date];
    }
    
    if (msgModel) {
        NSDictionary *userInfo = @{@"newMessageConversationId":@(msgModel.conversationId)};;
        notification.userInfo = userInfo;
    }
    
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}





@end
