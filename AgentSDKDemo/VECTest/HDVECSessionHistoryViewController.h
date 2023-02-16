//
//  HDVECSessionHistoryViewController.h
//  AgentSDKDemo
//
//  Created by easemob on 2023/2/16.
//  Copyright © 2023 环信. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^VECTestHangUpCallback)();
@interface HDVECSessionHistoryViewController : UIViewController
@property (nonatomic, copy) VECTestHangUpCallback vectestHangUpCallback;
@property (nonatomic, strong) UIWindow *window;
@end

NS_ASSUME_NONNULL_END
