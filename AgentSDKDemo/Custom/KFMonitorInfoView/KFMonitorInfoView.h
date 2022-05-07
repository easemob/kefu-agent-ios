//
//  KFMonitorInfoView.h
//  UICollectionViewTest
//
//  Created by 杜洁鹏 on 2018/3/22.
//  Copyright © 2018年 杜洁鹏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFMonitorInfoView.h"
#import "KFMonitorInfoViewItem.h"

typedef void (^MonitorUpdateCallback)(KFMonitorInfoViewItem *);

@class KFMonitorInfoViewItem;
@protocol KFMonitorInfoViewDelegate
- (void)didSelectedItemIndex:(NSInteger)index type:(HDObjectType)aType;
@end

@interface KFMonitorInfoView : UIView
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) id<KFMonitorInfoViewDelegate> delegate;
@property (nonatomic, strong, readonly) KFMonitorInfoViewItem *currentShowItem;
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)aItems;
- (void)updateCorrentShowItem:(KFMonitorInfoViewItem *)item;
@end
