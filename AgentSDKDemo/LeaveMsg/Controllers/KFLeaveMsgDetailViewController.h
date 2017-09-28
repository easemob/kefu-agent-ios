//
//  KFLeaveMsgDetailViewController.h
//  EMCSApp
//
//  Created by afanda on 16/11/3.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "KFBaseViewController.h"
@class KFLeaveMsgDetailViewController;
@protocol KFLeaveMsgDetailViewControllerDelegate <NSObject>

- (void)leaveMsgDetailViewController:(KFLeaveMsgDetailViewController *)vc;

@end

@interface KFLeaveMsgDetailViewController : KFBaseViewController
@property(nonatomic,weak) id<KFLeaveMsgDetailViewControllerDelegate> delegate;
- (instancetype)initWithModel:(HDLeaveMessage *)model;
@end
