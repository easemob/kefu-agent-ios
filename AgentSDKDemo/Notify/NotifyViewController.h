//
//  NotifyViewController.h
//  EMCSApp
//
//  Created by EaseMob on 16/3/1.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DXBaseViewController.h"

@interface NotifyViewController : DXBaseViewController

@property(nonatomic,copy) NSString *title1;
@property (strong, nonatomic) UIBarButtonItem *markReadItem;
@property (strong, nonatomic) UIBarButtonItem *headerViewItem;
@property(nonatomic,strong) UIBarButtonItem *readButtonItem;
@property(nonatomic,assign)HDNoticeType currentTabMenu;

- (void)loadDataWithPage:(NSInteger)page type:(HDNoticeType)notiType;

@end
