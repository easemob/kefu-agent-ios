//
//  HDAppManager.h
//  AgentSDKDemo
//
//  Created by easemob on 2023/2/10.
//  Copyright © 2023 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDAppManager : NSObject
@property (nonatomic, assign) BOOL isAnswer; // 当前是不是弹应答界面
+ (instancetype _Nullable )shareInstance;
@end

NS_ASSUME_NONNULL_END
