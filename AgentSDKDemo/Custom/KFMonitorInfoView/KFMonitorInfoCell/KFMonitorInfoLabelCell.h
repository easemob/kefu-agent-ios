//
//  KFMonitorInfoLabelCell.h
//  UICollectionViewTest
//
//  Created by 杜洁鹏 on 2018/3/25.
//  Copyright © 2018年 杜洁鹏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFMonitorInfoViewItem.h"
#import "KFMonitorInfoCell.h"
@protocol KFMonitorInfoLabelCellDelegate
- (void)didSelectedType:(NSInteger)aType itemIndex:(NSInteger)index;
@end

@interface KFMonitorInfoLabelCell : KFMonitorInfoCell
@property (nonatomic, strong) KFMonitorInfoViewItem *item;
@property (nonatomic, assign) id <KFMonitorInfoLabelCellDelegate> delegate;
@end
