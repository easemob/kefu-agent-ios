//
//  CustomerController.h
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//
//  "会话" -> “客服”

#import "DXTableViewController.h"
#import "DXBaseViewController.h"

@class CustomerController;
@protocol CustomerControllerDelegate <NSObject>
@optional
- (void)CustomerPushIntoChat:(UIViewController*)viewController;
@end

@interface CustomerController : DXTableViewController

@property (nonatomic, weak) id<CustomerControllerDelegate> delegate;

- (void)clearSession;

- (void)searhResign;

- (void)searhResignAndSearchDisplayNoActive;

- (void)loadData;

@end
