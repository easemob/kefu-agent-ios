//
//  EMHistoryTimeView.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/15.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMHistoryTimeView.h"

@interface EMHistoryTimeView ()

@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic, strong) UILabel *endLabel;

@end

@implementation EMHistoryTimeView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupHistoryTimeView];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    CGContextSetStrokeColorWithColor(context, RGBACOLOR(229, 229, 229, 1).CGColor);
    CGContextStrokeRect(context, CGRectMake(0, 43.5f, rect.size.width, 0.25f));
}

- (void)setupHistoryTimeView
{
    self.backgroundColor = [UIColor whiteColor];
    self.frame = CGRectMake(11, 4.f, KScreenWidth - 22, 87.f);
    self.layer.cornerRadius = 4.f;
    self.layer.borderWidth = 1.f;
    self.layer.borderColor = RGBACOLOR(229, 229, 229, 1).CGColor;
    self.layer.masksToBounds = YES;
    [self addSubview:self.startTimeView];
    [self addSubview:self.endTimeView];
}

- (UIView*)startTimeView
{
    if (_startTimeView == nil) {
        _startTimeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth - 22, 43)];
        [_startTimeView addSubview:self.startLabel];
        [_startTimeView addSubview:self.startTimeLabel];
    }
    return _startTimeView;
}

- (UIView*)endTimeView
{
    if (_endTimeView == nil) {
        _endTimeView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_startTimeView.frame) + 1.f, KScreenWidth - 22, 43)];
        [_endTimeView addSubview:self.endLabel];
        [_endTimeView addSubview:self.endTimeLabel];
    }
    return _endTimeView;
}

- (UILabel*)startLabel
{
    if (_startLabel == nil) {
        _startLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 70, 43)];
        _startLabel.font = [UIFont systemFontOfSize:17.f];
        _startLabel.textColor = RGBACOLOR(26, 26, 26, 1);
        _startLabel.text = @"开始时间";
    }
    return _startLabel;
}

- (UILabel*)endLabel
{
    if (_endLabel == nil) {
        _endLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 70, 43)];
        _endLabel.font = [UIFont systemFontOfSize:17.f];
        _endLabel.textColor = RGBACOLOR(26, 26, 26, 1);
        _endLabel.text = @"结束时间";
    }
    return _endLabel;
}

- (UILabel*)startTimeLabel
{
    if (_startTimeLabel == nil) {
        _startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width - 150 - 10, 0, 150, 43)];
        _startTimeLabel.font = [UIFont systemFontOfSize:17.f];
        _startTimeLabel.textColor = RGBACOLOR(26, 26, 26, 1);
        _startTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _startTimeLabel;
}

- (UILabel*)endTimeLabel
{
    if (_endTimeLabel == nil) {
        _endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width - 150 - 10, 0, 150, 43)];
        _endTimeLabel.font = [UIFont systemFontOfSize:17.f];
        _endTimeLabel.textColor = RGBACOLOR(26, 26, 26, 1);
        _endTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _endTimeLabel;
}

@end
