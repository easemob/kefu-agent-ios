//
//  KFDatePicker.m
//  EMCSApp
//
//  Created by afanda on 2/23/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import "KFDatePicker.h"

@interface KFDatePicker ()

@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSDate *date;

@end

@implementation KFDatePicker

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)setTag:(NSInteger)tag {
    self.datePicker.tag = tag;
}

- (void)setDate:(NSDate *)date {
    [_datePicker setDate:date];
}

-(UIDatePicker *)datePicker {
    if (_datePicker == nil) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 30, self.width, 200)];
        _datePicker.backgroundColor = [UIColor whiteColor];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        [_datePicker addTarget:self action:@selector(dateValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}

- (void)setMaxDate:(NSDate *)maxDate {
    _datePicker.maximumDate = maxDate;
}

- (void)setMinDate:(NSDate *)minDate {
    _datePicker.minimumDate = minDate;
}


- (void)dateValueChanged:(UIDatePicker *)picker {
    _date = picker.date;
}

- (void)initUI {
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    UIButton *ok = [UIButton buttonWithType:UIButtonTypeCustom];
    ok.frame = CGRectMake(self.width-60, 0, 40, 30);
    [ok setTitleColor:RGBACOLOR(41, 169, 234, 1) forState:UIControlStateNormal];
    [ok setTitle:@"保存" forState:UIControlStateNormal];
    [ok addTarget:self action:@selector(okClicked) forControlEvents:UIControlEventTouchUpInside];
    UIView *backV = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-230, self.width, 200)];
    backV.backgroundColor = [UIColor whiteColor];
    [backV addSubview:ok];
    [backV addSubview:self.datePicker];
    [self addSubview:backV];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self removeFromSuperview];
}
- (void)okClicked {
    [self removeFromSuperview];
    if (_delegate && [_delegate respondsToSelector:@selector(dateClicked:)]) {
        [_delegate dateClicked:self.datePicker];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
