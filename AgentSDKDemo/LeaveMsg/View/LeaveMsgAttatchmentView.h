//
//  LeaveMsgAttatchmentView.h
//  CustomerSystem-ios
//
//  Created by EaseMob on 16/7/25.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LeaveMsgAttatchmentViewDelegate <NSObject>

- (void)didRemoveAttatchment:(NSInteger)index;

@end

@interface LeaveMsgAttatchmentView : UIView

@property (nonatomic, strong) id<LeaveMsgAttatchmentViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame
                         edit:(BOOL)edit
                        model:(HLeaveMessageCommentAttachment *)model;

- (instancetype)initWithFrame:(CGRect)frame
                         edit:(BOOL)edit
                        kfmodel:(HLeaveMessageCommentAttachment *)model;

+ (CGFloat)widthForName:(NSString*)name maxWidth:(CGFloat)maxWidth;

@end
