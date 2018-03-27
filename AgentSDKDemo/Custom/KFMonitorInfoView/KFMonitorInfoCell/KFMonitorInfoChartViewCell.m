//
//  KFMonitorInfoChartViewCell.m
//  UICollectionViewTest
//
//  Created by 杜洁鹏 on 2018/3/23.
//  Copyright © 2018年 杜洁鹏. All rights reserved.
//

#import "KFMonitorInfoChartViewCell.h"

@interface KFMonitorInfoChartViewCell() {
    AAChartModel *_aaChartModel;
}
@property (nonatomic, strong) AAChartView *aaChartView;
@end


@implementation KFMonitorInfoChartViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _aaChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 200)];
        [_aaChartView setScrollEnabled:NO];
        [self.contentView addSubview:_aaChartView];
        _aaChartView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[self configureTheConstraintArrayWithItem:_aaChartView toItem:self]];
    }
    
    return self;
}

- (void)setItem:(KFMonitorInfoViewItem *)item {
    _item = item;
    _aaChartModel = item.chartModel;
    [self.aaChartView aa_drawChartWithChartModel:_aaChartModel];
}


@end
