//
//  HDManager.m
//  AgentSDKDemo
//
//  Created by afanda on 4/20/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "KFManager.h"
#import "HomeViewController.h"

@interface KFManager () <HDChatManagerDelegate,UIAlertViewDelegate>

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

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)showMainViewController {
    [self removeDelegates];
    [self addDelegates];
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate showHomeViewController];
}

- (void)showLoginViewController {
    [self removeDelegates];
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
    [_noti loadDataWithPage:1 type:_noti.currentTabMenu];
}
#pragma mark - 其他
- (void)roleChange:(RolesChangeType)type {
    AppDelegate *app = self.appDelegate;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的权限发生了变更，请重新登陆后查看" delegate:app cancelButtonTitle:@"确定" otherButtonTitles: nil];
    alert.tag = kShowLoginViewControllerTag;
    [alert show];
}

//客服需要重新登录
- (void)userAccountNeedRelogin:(HDAutoLogoutReason)reason {
    NSString *tip;
    switch (reason) {
        case HDAutoLogoutReasonDefaule: {
            break;
        }
            
        case HDUserAccountDidRemoveFromServer: {
            tip = @"当前账号被管理员强制下线";
            break;
        }
            
        case HDUserAccountDidLoginFromOtherDevice: {
            tip = @"当前账号从其他平台登录";
            break;
        }
        case HDAutoLogoutReasonAgentDelete: {
            tip = @"当前账号被管理员删除";
            break;
        }
        default:
            tip = @"登录信息过期";
            break;
    }
    if (reason != HDAutoLogoutReasonDefaule) {
        AppDelegate * appDelegate = [KFManager sharedInstance].appDelegate;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:tip delegate:appDelegate cancelButtonTitle:@"确定" otherButtonTitles: nil];
        alert.tag = kShowLoginViewControllerTag;
        [alert show];
    } else {
        [[KFManager sharedInstance] showLoginViewController];
    }
}

- (void)allowAgentChangeMaxSessions:(BOOL)allow  {
    [_conversation showSetMaxSession:allow];
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


- (void)addDelegates {
    [[HDClient sharedClient] addDelegate:self delegateQueue:nil];
    [[HDClient sharedClient].chatManager addDelegate:self];
}

- (void)removeDelegates {
    [[HDClient sharedClient] removeDelegate:self];
    [[HDClient sharedClient].chatManager removeDelegate:self];
}



@end
