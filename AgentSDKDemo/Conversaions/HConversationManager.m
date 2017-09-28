//
//  HConversationManager.m
//  EMCSApp
//
//  Created by afanda on 7/10/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import "HConversationManager.h"
#import "HomeViewController.h"
#import "ChatViewController.h"
@implementation HConversationManager
singleton_implementation(HConversationManager);
-(instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
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
