//
//  ConversationsController.h
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversationsController : UIViewController

@property (strong, nonatomic) UIView *titleView;

@property (strong, nonatomic) UIBarButtonItem *rightItem;

@property (strong, nonatomic) UIBarButtonItem *headerViewItem;

- (void)refreshData;

@end
