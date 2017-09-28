//
//  HistoryConversationsController.h
//  EMCSApp
//
//  Created by dhc on 15/4/11.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "DXBaseViewController.h"

@interface HistoryConversationsController : DXBaseViewController
{
    NSInteger _page;
}

@property (copy, nonatomic) NSString* userId;

- (void)initData;

- (void)loadData;

- (void)reloadData;

@end
