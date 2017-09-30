//
//  HDManager.m
//  AgentSDKDemo
//
//  Created by afanda on 4/20/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "KFManager.h"
#import "AppDelegate.h"
#import "HomeViewController.h"

@interface KFManager () <HDChatManagerDelegate>

@end


static const CGFloat kDefaultPlaySoundInterval = 3.0;
@implementation KFManager
singleton_implementation(KFManager)

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (void)showMainViewController {
    [[HDClient sharedClient].chatManager addDelegate:self];
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate showHomeViewController];
}

- (void)showLoginViewController {
    [[HDClient sharedClient] removeDelegate:self];
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate showLoginViewController];
     [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
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

    // 收到消息时，震动
    [[EMCDDeviceManager sharedInstance] playVibration];
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
    NSLog(@"会话被管理员转接");
    
}
//会话被管理员关闭
- (void)conversationClosedByAdminWithServiceSessionId:(NSString *)serviceSessionId {
    NSLog(@"会话被管理员关闭");
}
//会话自动关闭
- (void)conversationAutoClosedWithServiceSessionId:(NSString *)serviceSessionId {
    NSLog(@"会话自动关闭");
}
//会话最后一条消息变化
- (void)conversationLastMessageChanged:(HDMessage *)message {
    NSLog(@"会话最后一条消息变化");
}
//有新会话
- (void)newConversationWithSessionId:(NSString *)sessionId {
    NSLog(@"有新会话");
    [_conversation refreshData];
}
//客服列表改变
- (void)agentUsersListChange {
    NSLog(@"客服列表改变");
    [_conversation refreshData];
}

#pragma mark - 待接入
//待接入改变
- (void)waitListChange {
    NSLog(@"待接入改变");
    [_wait loadData];
}

#pragma mark - 通知中心
//通知中心改变
- (void)notificationChange {
    NSLog(@"通知中心改变");
    [_noti loadDataWithPage:1 type:HDNoticeTypeAll];
}
#pragma mark - 其他
- (void)roleChange:(RolesChangeType)type {
    NSLog(@"身份改变");
    [self showMainViewController];
}
//连接状态改变
- (void)connectionStateDidChange:(HDConnectionState)aConnectionState {
    NSLog(@"连接状态改变");
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


- (NSString *)currentSessionId {
    if (_curChatViewConvtroller == nil) {
        return nil;
    }
    return _curChatViewConvtroller.conversationModel.sessionId;
}

- (void)setTabbarBadgeValueWithAllConversations:(NSMutableArray *)allConversations {
    NSInteger unreadCount=0;
    for (HDConversation *model in allConversations) {
        unreadCount+= model.unreadCount;
    }
    _curConversationNum = allConversations.count;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SET_MAX_SERVICECOUNT object:nil];
    [[HomeViewController HomeViewController] setConversationWithBadgeValue:[self getBadgeValueWithUnreadCount:unreadCount]];
}

- (void)setNavItemBadgeValueWithAllConversations:(NSMutableArray *)allConversations {
    if (_curChatViewConvtroller == nil) {
        return;
    }
    NSString *curSessionId = _curChatViewConvtroller.conversationModel.sessionId;
    NSInteger unreadCount = 0;
    for (HDConversation *model in allConversations) {
        if (![model.sessionId isEqualToString:curSessionId]) {
            unreadCount+=model.unreadCount;
        }
    }
    _curChatViewConvtroller.unreadBadgeValue = [self getBadgeValueWithUnreadCount:unreadCount];
}


//private
- (NSString *)getBadgeValueWithUnreadCount:(NSInteger)unreadCount {
    if (unreadCount<=0) {
        return nil;
    }
    if (unreadCount>99) {
        return @"99+";
    }
    return [NSString stringWithFormat:@"%ld",(long)unreadCount];
}




@end
