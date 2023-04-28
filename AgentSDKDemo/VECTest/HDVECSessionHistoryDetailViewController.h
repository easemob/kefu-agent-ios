//
//  HDVECSessionHistoryDetailViewController.h
//  AgentSDKDemo
//
//  Created by easemob on 2023/2/16.
//  Copyright © 2023 环信. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDVECSessionHistoryDetailViewController : UIViewController
@property (nonatomic, strong) NSString * rtcSessionId;
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UIWindow *window;
@end

NS_ASSUME_NONNULL_END
