//
//  WaitQueueViewController.h
//  EMCSApp
//
//  Created by EaseMob on 16/2/29.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "DXBaseViewController.h"

#import "HConversationViewController.h"

@interface WaitQueueViewController : DXBaseViewController
{
    HDConversationType _type;
    NSInteger _page;
}

@property (nonatomic, strong) UIBarButtonItem *headerViewItem;
@property (nonatomic, strong) UIBarButtonItem *optionItem;

@property (nonatomic) BOOL showSearchBar;

@property (nonatomic) BOOL isFetchedData;

@property (nonatomic, weak) id<ConversationTableControllerDelegate> conDelegate;

- (instancetype)initWithStyle:(UITableViewStyle)style
                         type:(HDConversationType)type;

- (void)loadData;

- (void)clearSeesion;

- (void)searhResign;

- (void)searhResignAndSearchDisplayNoActive;

@end
