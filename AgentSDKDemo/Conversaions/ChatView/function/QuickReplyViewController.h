//
//  QuickReplyViewController.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/16.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "DXTableViewController.h"

@protocol QuickReplyViewControllerDelegate <NSObject>

- (void)sendQuickReplyMessage:(NSString *)message;

@end

@interface QuickReplyViewController : DXTableViewController

@property (weak, nonatomic) id<QuickReplyViewControllerDelegate> delegate;

@end
