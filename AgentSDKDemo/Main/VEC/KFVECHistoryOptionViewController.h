//
//  KFVECHistoryOptionViewController.h
//  AgentSDKDemo
//
//  Created by easemob on 2023/4/25.
//  Copyright © 2023 环信. All rights reserved.
//

#import "DXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef enum {
    VECEMHistoryOptionType,
    VECEMWaitingQueueType
}VECEMOptionType;

@protocol VECHistoryOptionDelegate <NSObject>
@optional
- (void)vecHistoryOptionWithParameters:(NSMutableDictionary*)parameters;
@end

@interface KFVECHistoryOptionViewController : DXBaseViewController
@property (nonatomic, assign) VECEMOptionType type;

@property (nonatomic,weak) id<VECHistoryOptionDelegate> optionDelegate;

@end

NS_ASSUME_NONNULL_END
