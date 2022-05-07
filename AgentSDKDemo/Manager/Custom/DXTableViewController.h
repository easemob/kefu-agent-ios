//
//  DXTableViewController.h
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DXTableViewController;
@protocol DXTableViewControllerDelegate <NSObject>
- (void)dxtableView:(DXTableViewController *)aTableVC userInfo:(NSDictionary *)userInfo;
@end

@interface DXTableViewController : UITableViewController

@property (nonatomic, strong) UIBarButtonItem *backItem;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIButton *titleBtn;

@property (nonatomic, assign) id <DXTableViewControllerDelegate> dxDelegate;

- (void)dxDelegateAction:(NSDictionary *)userInfo;

@end
