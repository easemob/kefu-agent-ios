//
//  KFMonitorInstrumentView.h
//  UICollectionViewTest
//
//  Created by 杜洁鹏 on 2018/3/26.
//  Copyright © 2018年 杜洁鹏. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KFMonitorInstrumentPin : UIView

@end

@interface KFMonitorInstrumentView : UIView
@property (nonatomic, assign, readonly) NSInteger currCount;
@property (nonatomic, assign, readonly) NSInteger maxCount;

- (instancetype)initWithFrame:(CGRect)frame
                         name:(NSString *)aName
                 currentCount:(NSInteger)currCount
                     maxCount:(NSInteger)aMaxCount;

- (void)updateCurrentCount:(NSInteger)aCurrCount maxCount:(NSInteger)aMaxCount;

@end
