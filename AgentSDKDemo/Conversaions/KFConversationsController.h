//
//  ConversationsController.h
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//
//包括进行中会话和客服会话

#import <UIKit/UIKit.h>

@interface KFConversationsController : UIViewController

@property (nonatomic, strong) UIView *titleView;

@property (nonatomic, strong) UIBarButtonItem *rightItem;

@property (nonatomic, strong) UIBarButtonItem *headerViewItem;

- (void)refreshData;

- (void)showSetMaxSession:(BOOL)show;

@end
