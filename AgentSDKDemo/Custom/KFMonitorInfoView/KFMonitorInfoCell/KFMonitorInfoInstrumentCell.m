//
//  KFMonitorInfoInstrumentCell.m
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/3/26.
//  Copyright © 2018年 环信. All rights reserved.
//

#import "KFMonitorInfoInstrumentCell.h"
#import "KFMonitorInstrumentView.h"

@interface KFMonitorInfoInstrumentCell(){
    KFMonitorInstrumentModel *_model;
}
@property (nonatomic, strong) KFMonitorInstrumentView *instrumentView;
@end

@implementation KFMonitorInfoInstrumentCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.instrumentView];
        [self addConstraints:[self configureTheConstraintArrayWithItem:self.instrumentView toItem:self]];
    }
    
    return self;
}

- (void)setItem:(KFMonitorInfoViewItem *)item {
    _item = item;
    _model = (KFMonitorInstrumentModel *)item.infos.firstObject;
    [self.instrumentView updateCurrentCount:_model.currCount maxCount:_model.maxCount];
}

- (KFMonitorInstrumentView *)instrumentView {
    if (!_instrumentView) {
        _instrumentView = [[KFMonitorInstrumentView alloc]
                           initWithFrame:self.bounds
                           name:@"今日待接入人数/最大"
                           currentCount:10
                           maxCount:100];
    }
    
    return _instrumentView;
}

@end
