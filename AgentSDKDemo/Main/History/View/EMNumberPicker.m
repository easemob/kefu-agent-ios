//
//  EMNumberPicker.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/10.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMNumberPicker.h"

#import "SBTickerView.h"

@interface EMNumberPicker ()

@property (nonatomic, strong) SBTickerView *numberTicker;

@end

@implementation EMNumberPicker

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 80, 60);
    }
    return self;
}

- (void)setupView
{
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 0.5f;
    [self addSubview:self.numberTicker];
}

- (SBTickerView*)numberTicker
{
    if (_numberTicker == nil) {
        _numberTicker = [[SBTickerView alloc] initWithFrame:CGRectMake((self.width - 50)/2, (self.height - 40)/2, 50, 40)];
    }
    return _numberTicker;
}

@end
