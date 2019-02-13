//
//  DXBaseViewController.h
//  EMCSApp
//
//  Created by EaseMob on 15/5/11.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXBaseViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIBarButtonItem *backItem;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIButton *titleBtn;

@property (nonatomic, strong) UITableView *tableView;

@end
