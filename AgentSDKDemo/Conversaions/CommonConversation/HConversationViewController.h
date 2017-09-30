//
//  ConversationTableController.h
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//
//  "会话"列表

#import "DXTableViewController.h"
#import "DXBaseViewController.h"

#import "LocalDefine.h"

@class HConversationViewController;
@protocol ConversationTableControllerDelegate <NSObject>
@optional
- (void)ConversationPushIntoChat:(UIViewController*)viewController;
@end

@interface HConversationViewController : DXTableViewController
{
    HDConversationType _type;
    NSInteger _page;
}

@property (nonatomic) BOOL showSearchBar;


@property (nonatomic, weak) id<ConversationTableControllerDelegate> conDelegate;

- (instancetype)initWithStyle:(UITableViewStyle)style
                         type:(HDConversationType)type;

- (void)loadData;

- (void)clearSeesion;

- (void)searhResign;

- (void)searhResignAndSearchDisplayNoActive;

- (void)connectionStateDidChange:(HDConnectionState)aConnectionState;

- (void)conversationLastMessageChanged:(HDMessage *)message;

- (void)newConversationWithSessionId:(NSString *)sessionId;

@end
