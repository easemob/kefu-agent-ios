//
//  QuickReplyAddViewController.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/17.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QuickReplyModel.h"

@protocol QuickReplyAddViewDelegate <NSObject>

- (void)addQuickReplyMessage:(QuickReplyMessageModel*)model;

@end

@interface QuickReplyAddViewController : EMBaseViewController

@property (copy, nonatomic) NSString *parentId;

@property (assign, nonatomic) NSInteger leaf;

@property (strong, nonatomic) QuickReplyMessageModel *qrMsgModel;

@property (weak, nonatomic) id<QuickReplyAddViewDelegate> delegate;

@end
