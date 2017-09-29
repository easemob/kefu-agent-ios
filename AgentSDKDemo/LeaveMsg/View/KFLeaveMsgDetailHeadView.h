//
//  KFLeaveMsgDetailHeadView.h
//  EMCSApp
//
//  Created by afanda on 16/11/3.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat rowHeight;
@interface KFLeaveMsgDetailHeadView : UIView

@property(nonatomic,copy) void(^tapTableview)();

- (instancetype)initWithModel:(HDLeaveMessage *)model dataSource:(NSMutableArray *)dataSource height:(CGFloat)height;

@end
