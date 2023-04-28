//
//  DXDatePickerView.m
//  EMCSApp
//
//  Created by dhc on 15/4/11.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "DXDatePickerView.h"

@implementation DXDatePickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(okAction)];
//        [self addGestureRecognizer:tap];
        
        _datePicker = [[UIDatePicker alloc] init];
        float height = _datePicker.frame.size.height;
        _datePicker.frame = CGRectMake(0, 50, self.frame.size.width, KScreenHeight - height);
        _datePicker.backgroundColor = [UIColor whiteColor];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        NSDate *minDate = [formatter dateFromString:@"2012-01-01"];
        _datePicker.minimumDate = minDate;
        [self addSubview:_datePicker];
        
        _okButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 80, 5, 70, 32)];
        [_okButton setTitle:@"完成" forState:UIControlStateNormal];
        [_okButton addTarget:self action:@selector(okAction) forControlEvents:UIControlEventTouchUpInside];
//        [_okButton setBackgroundColor:[UIColor colorWithRed:0 green:177 / 255.0 blue:147 / 255.0 alpha:1.0]];
        [_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_okButton setBackgroundImage:[[UIImage imageNamed:@"button_blue2"] stretchableImageWithLeftCapWidth:10 topCapHeight:5] forState:UIControlStateNormal];
        [_okButton setBackgroundImage:[[UIImage imageNamed:@"button_blue2_select"] stretchableImageWithLeftCapWidth:10 topCapHeight:5] forState:UIControlStateHighlighted];
        [self addSubview:_okButton];
        
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [UIColor lightGrayColor];
        line.frame = CGRectMake(0, 50 - 0.5, CGRectGetWidth(self.frame), 0.5);
        [self addSubview:line];
        
        _cancleButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 100, 0, 50, 30)];
        [_cancleButton setTitle:@"取消" forState:UIControlStateNormal];
        _cancleButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_cancleButton addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchUpInside];
        [_cancleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [self addSubview:_cancleButton];
    }
    
    return self;
}

- (void)okAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(datePickerDidSelectedDate:)]) {
        [_delegate datePickerDidSelectedDate:_datePicker.date];
    }
    [self removeFromSuperview];
}

- (void)cancleAction
{
    [self removeFromSuperview];
}

+ (CGFloat)datePickerViewHeight
{
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    return datePicker.height + 50;
}

@end
