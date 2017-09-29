//
//  HDManager.m
//  AgentSDKDemo
//
//  Created by afanda on 4/20/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "KFManager.h"
#import "AppDelegate.h"


@interface KFManager () <HDChatManagerDelegate>

@end
static const CGFloat kDefaultPlaySoundInterval = 3.0;
@implementation KFManager
static KFManager *_manager = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[KFManager alloc] init];
    });
    return _manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[HDClient sharedClient].chatManager addDelegate:self];
    }
    
    return self;
}

- (void)showMainViewController {
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate showHomeViewController];
}

- (void)showLoginViewController {
    [[HDClient sharedClient] removeDelegate:self];
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


- (void)playSoundAndVibration{
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
}


- (void)messagesDidReceive:(NSArray<HDMessage *> *)aMessages {
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    for (HDMessage *message in aMessages) {
        if (message.type == HDMessageBodyTypeCommand) {
            return;
        }
        switch (state) {
            case UIApplicationStateActive:
                [self playSoundAndVibration];
                break;
            case UIApplicationStateInactive:
                [self playSoundAndVibration];
                break;
            case UIApplicationStateBackground:
                [self showNotificationWithMessage:@"有一条新消息" message:message];
                break;
            default:
                break;
        }
    }
}

#pragma mark - 会话

//会话被管理员转接
- (void)conversationTransferedByAdminWithServiceSessionId:(NSString *)serviceSessionId {
    
}
//会话被管理员关闭
- (void)conversationClosedByAdminWithServiceSessionId:(NSString *)serviceSessionId {
    
}
//会话自动关闭
- (void)conversationAutoClosedWithServiceSessionId:(NSString *)serviceSessionId {
    
}
//会话最后一条消息变化
- (void)conversationLastMessageChanged:(HDMessage *)message {
    
}
//有新会话
- (void)newConversationWithSessionId:(NSString *)sessionId {
    [_conversation refreshData];
}
//客服列表改变
- (void)agentUsersListChange {
    [_conversation refreshData];
}

#pragma mark - 待接入
//待接入改变
- (void)waitListChange {
    [_wait loadData];
}

#pragma mark - 通知中心
//通知中心改变
- (void)notificationChange {
    [_noti loadDataWithPage:1 type:HDNoticeTypeAll];
}
#pragma mark - 其他
- (void)roleChange:(RolesChangeType)type {
    [self showMainViewController];
}
//连接状态改变
- (void)connectionStateDidChange:(HDConnectionState)aConnectionState {
    
}
//客服需要重新登录
- (void)userAccountNeedRelogin {
    [self showLoginViewController];
}



- (void)showNotificationWithMessage:(NSString *)content message:(HDMessage *)message;
{
    NSInteger PreviousNum = [UIApplication sharedApplication].applicationIconBadgeNumber;
    [UIApplication sharedApplication].applicationIconBadgeNumber = ++PreviousNum;
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    notification.alertBody = content;
    notification.alertAction = NSLocalizedString(@"open", @"Open");
    notification.timeZone = [NSTimeZone defaultTimeZone];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
    } else {
        notification.soundName = UILocalNotificationDefaultSoundName;
        self.lastPlaySoundDate = [NSDate date];
    }
    
    if (message) {
        NSDictionary *userInfo = @{@"newMessageConversationId":@(message.conversationId)};;
        notification.userInfo = userInfo;
    }
    
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}





@end
