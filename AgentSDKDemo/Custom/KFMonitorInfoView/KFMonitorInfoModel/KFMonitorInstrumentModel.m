//
//  KFMonitorInstrumentModel.m
//  UICollectionViewTest
//
//  Created by 杜洁鹏 on 2018/3/25.
//  Copyright © 2018年 杜洁鹏. All rights reserved.
//

#import "KFMonitorInstrumentModel.h"

@implementation KFMonitorInstrumentModel
- (instancetype)initWithCurrentCount:(NSInteger)aCurr maxCount:(NSInteger)aMax {
    if (self = [super init]) {
        _currCount = aCurr;
        _maxCount = aMax;
    }
    
    return self;
}
@end
