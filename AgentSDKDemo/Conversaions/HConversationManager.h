//
//  HConversationManager.h
//  EMCSApp
//
//  Created by afanda on 7/10/17.
//  Copyright © 2017 easemob. All rights reserved.
//
//管理会话

#import <Foundation/Foundation.h>

@class ChatViewController;

@interface HConversationManager : NSObject
singleton_interface(HConversationManager)

/**
 当前聊天控制器,进入会话的时候传入
 */
@property(nonatomic,strong) ChatViewController *curChatViewConvtroller;


/**
 当前会话数
 */
@property(nonatomic,assign) NSInteger curConversationNum;


/**
 当前会话id
 */
@property(nonatomic,strong,readonly) NSString *currentSessionId;

- (void)setTabbarBadgeValueWithAllConversations:(NSMutableArray *)allConversations;

- (void)setNavItemBadgeValueWithAllConversations:(NSMutableArray *)allConversations;

@end







