//
//  KFLeaveMsgDetailViewController.h
//  EMCSApp
//
//  Created by afanda on 16/11/3.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "KFBaseViewController.h"

#define kLeaveMessageDetailChanged @"leaveMessageDetailChanged"

@interface KFLeaveMsgDetailViewController : KFBaseViewController
- (instancetype)initWithModel:(HLeaveMessage *)model;
@end
