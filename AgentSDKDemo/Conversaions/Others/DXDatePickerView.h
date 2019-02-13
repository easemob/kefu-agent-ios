//
//  DXDatePickerView.h
//  EMCSApp
//
//  Created by dhc on 15/4/11.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DXDatePickerViewDelegate <NSObject>

- (void)datePickerDidSelectedDate:(NSDate *)date;

@end

@interface DXDatePickerView : UIView
{
    UIButton *_okButton;
    UIButton *_cancleButton;
}

@property (weak, nonatomic) id<DXDatePickerViewDelegate> delegate;

@property (nonatomic, strong) UIDatePicker *datePicker;

+ (CGFloat)datePickerViewHeight;

@end
