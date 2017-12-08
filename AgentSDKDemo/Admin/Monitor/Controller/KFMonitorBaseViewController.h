//
//  KFMonitorBaseViewController.h
//  AgentSDKDemo
//
//  Created by afanda on 12/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFArrowButtonView.h"
#import "SRRefreshView.h"


@interface KFMonitorBaseViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,KFArrowButtonViewDelegate,SRRefreshDelegate>

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSMutableArray *dataSource;

@property(nonatomic,strong) NSTimer *timer;

@property (strong, nonatomic) SRRefreshView *slimeView;

- (void)loadData;

- (NSArray *)sortArray:(NSArray *)array isSort:(BOOL)isSort;

@end
