//
//  EMTimePickerViewController.h
//  EMCSApp
//
//  Created by EaseMob on 16/3/9.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DXBaseViewController.h"

@protocol EMTimePickerViewDelegate <NSObject>

- (void)saveStartDate:(NSDate*)startDate endDate:(NSDate*)endDate;

@end

@interface EMTimePickerViewController : DXBaseViewController

@property (nonatomic, weak) id<EMTimePickerViewDelegate> delegate;

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;

@property (nonatomic, assign) BOOL isSettingLeft;

@end
