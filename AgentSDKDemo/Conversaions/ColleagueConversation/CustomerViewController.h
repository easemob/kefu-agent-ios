//
//  CustomerViewController.h
//  EMCSApp
//
//  Created by EaseMob on 15/5/14.
//  Copyright (c) 2015年 easemob. All rights reserved.
//
//  在"客服"下面

#import <UIKit/UIKit.h>

#import "CustomerController.h"

#import "HConversationViewController.h"

@interface CustomerViewController : EMBaseViewController

@property (nonatomic, strong) CustomerController *customerController;

@property (nonatomic, weak) id<ConversationTableControllerDelegate> conDelegate;

@end
