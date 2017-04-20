//
//  KFDatePicker.m
//  EMCSApp
//
//  Created by __阿彤木_ on 2/23/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import "KFDatePicker.h"

@interface KFDatePicker ()

@property(nonatomic,strong) UIDatePicker *datePicker;
@property(nonatomic,strong) NSDate *date;

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

-(UIDatePicker *)datePicker {
    if (_datePicker == nil) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 30, self.width, self.height-30)];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        [_datePicker addTarget:self action:@selector(dateValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}

- (void)dateValueChanged:(UIDatePicker *)picker {
    _date = picker.date;
}

- (void)initUI {
    self.backgroundColor = [UIColor whiteColor];
    UIButton *ok = [UIButton buttonWithType:UIButtonTypeCustom];
    ok.frame = CGRectMake(self.width-60, 0, 40, 30);
    [ok setTitle:@"确定" forState:UIControlStateNormal];
    [ok setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [ok addTarget:self action:@selector(okClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:ok];
    
    [self addSubview:self.datePicker];
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
