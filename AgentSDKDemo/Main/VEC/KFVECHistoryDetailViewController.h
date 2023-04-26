//
//  KFVECHistoryDetailViewController.h
//  AgentSDKDemo
//
//  Created by easemob on 2023/4/26.
//  Copyright © 2023 环信. All rights reserved.
//

#import "DXBaseViewController.h"
#import "KFVecCallHistoryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KFVECHistoryDetailViewController : DXBaseViewController

@property (nonatomic, strong) KFVecCallHistoryModel * callModel;

@end

NS_ASSUME_NONNULL_END
