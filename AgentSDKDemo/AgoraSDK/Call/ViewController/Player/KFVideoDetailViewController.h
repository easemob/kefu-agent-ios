//
//  KFVideoDetailViewController.h
//  AgentSDKDemo
//
//  Created by houli on 2022/2/23.
//  Copyright © 2022 环信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFPlayerVideoBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KFVideoDetailViewController : KFPlayerVideoBaseViewController

@property (nonatomic, strong) NSArray *recordVideos;
@property (nonatomic, assign) NSInteger  currentVideoIdx;
@property (nonatomic, strong) NSString * callId;

@end

NS_ASSUME_NONNULL_END
