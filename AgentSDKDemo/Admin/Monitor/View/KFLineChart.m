//
//  KFLineChart.m
//  AgentSDKDemo
//
//  Created by afanda on 12/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "KFLineChart.h"
#import "UIColor+KFColor.h"
#import "KFStatuLabel.h"

#define margin 10

@implementation KFLineChartModel

@end

@implementation KFLineChart
{
    UIView *_line;
    NSArray *_models;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 8)];
        _line.layer.cornerRadius = 8.0/2;
        _line.layer.masksToBounds = YES;
        [self addSubview:_line];
    }
    return self;
}

- (void)setModels:(NSArray *)models {
    CGFloat totalNum = 0;
    NSInteger index = 0;
    CGFloat stwidth = 50;
    for (KFLineChartModel *model in models) {
        KFStatuLabel *label = [[KFStatuLabel alloc] initWithFrame:CGRectMake(0+index*stwidth, CGRectGetMaxY(_line.frame)+margin, stwidth, 20) status:model.status];
        label.text = [NSString stringWithFormat:@"%ld",(long)model.count];
        [self addSubview:label];
        index ++;
        totalNum += model.count;
    }
    for (KFLineChartModel *model in models) {
        model.percentage = model.count/totalNum;
    }
    _models = models;
}

- (void)layoutSubviews {
    _line.width = self.width;
    [self initUIWithModels:_models];
}

- (void)initUIWithModels:(NSArray *)models {
    CGFloat preLabelMaxX = 0;
//    [_line.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (KFLineChartModel *model in models) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(preLabelMaxX, 0, self.width*model.percentage, self.height)];
        preLabelMaxX = CGRectGetMaxX(label.frame);
        label.backgroundColor = [self getColorWithStatus:model.status];
        [_line addSubview:label];
    }
}

- (UIColor *)getColorWithStatus:(HDAgentLoginStatus)status {
    NSString *colorName = @"";
    switch (status) {
        case HDAgentLoginStatusOnline: {
            colorName = @"#9FF806";
            break;
        }
        case HDAgentLoginStatusBusy: {
            colorName = @"#F9331C";
            break;
        }
        case HDAgentLoginStatusLeave:{
            colorName = @"#29A9EA";
            break;
        }
        case HDAgentLoginStatusHidden: {
            colorName = @"#EFBB57";
            break;
        }
        case HDAgentLoginStatusOffline: {
            colorName = @"#D8D8D8";
            break;
        }
        default:
            break;
    }
    return [UIColor colorWithHexString:colorName];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
