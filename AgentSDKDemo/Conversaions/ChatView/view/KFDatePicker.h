//
//  KFDatePicker.h
//  EMCSApp
//
//  Created by afanda on 2/23/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KFDatePickerDelegate <NSObject>

- (void)dateClicked:(UIDatePicker *)datePicker;

@end


@interface KFDatePicker : UIView

@property(nonatomic,strong) NSDate *maxDate;
@property(nonatomic,strong) NSDate *minDate;
@property(nonatomic,assign) id<KFDatePickerDelegate> delegate;

- (void)setDate:(NSDate *)date;

@end
