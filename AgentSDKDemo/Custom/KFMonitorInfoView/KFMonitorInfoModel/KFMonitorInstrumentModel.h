//
//  KFMonitorInstrumentModel.h
//  UICollectionViewTest
//
//  Created by 杜洁鹏 on 2018/3/25.
//  Copyright © 2018年 杜洁鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KFMonitorInstrumentModel : NSObject
- (instancetype)initWithCurrentCount:(NSInteger)aCurr maxCount:(NSInteger)aMax;
@property (nonatomic, assign, readonly) NSInteger currCount;
@property (nonatomic, assign, readonly) NSInteger maxCount;
@end
