//
//  KFVECHistoryController.h
//  AgentSDKDemo
//
//  Created by easemob on 2023/4/24.
//  Copyright © 2023 环信. All rights reserved.
//

#import "DXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KFVECHistoryController : DXBaseViewController

{
    NSInteger _page;
}

@property (nonatomic, copy) NSString * userId;

- (void)initData;

- (void)loadData;

- (void)reloadData;
@end

NS_ASSUME_NONNULL_END
