//
//  HistoryOptionViewController.h
//  EMCSApp
//
//  Created by EaseMob on 16/3/2.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "DXBaseViewController.h"

typedef enum {
    EMHistoryOptionType,
    EMWaitingQueueType
}EMOptionType;

@protocol HistoryOptionDelegate <NSObject>
@optional
- (void)historyOptionWithParameters:(NSMutableDictionary*)parameters;
@end

@interface HistoryOptionViewController : DXBaseViewController

@property (nonatomic, assign) EMOptionType type;

@property (nonatomic,weak) id<HistoryOptionDelegate> optionDelegate;

@end
