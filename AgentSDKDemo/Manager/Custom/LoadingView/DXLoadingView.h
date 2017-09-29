//
//  DXLoadingView.h
//  EventRecord
//
//  Created by dhcdht on 14-5-20.
//  Copyright (c) 2014年 XDStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXLoadingView : UIView

//颜色，默认黑色
@property (strong, nonatomic) UIColor *contentColor;

//取消回调
@property (copy) void (^cancleCompletion)(BOOL didCancle);

/**
 *  显示到[UIApplication sharedApplication].keyWindow上
 */
- (void)showWithTitle:(NSString *)title;
/**
 *  显示到页面toView上
 *
 *  @param title  标题（默认“请稍后...”）
 *  @param toView 显示到哪个页面
 */
- (void)showWithTitle:(NSString *)title toView:(UIView *)toView;
/**
 *  移除页面
 */
- (void)hide;

#pragma mark - 类方法

/**
 *  显示加载到[UIApplication sharedApplication].keyWindow上
 *
 *  @param title            标题（默认“请稍后...”）
 *  @param cancleCompletion 取消回调（!=nil时，显示取消按钮）
 *
 *  @return DXLoadingView
 */
+ (instancetype)showWithTitle:(NSString *)title cancleCompletion:(void (^)(BOOL didCancle))cancleCompletion;
/**
 *  在页面toView上显示加载
 *
 *  @param title            标题（默认“请稍后...”）
 *  @param toView           显示到哪个页面（==nil时，=[UIApplication sharedApplication].keyWindow）
 *  @param cancleCompletion 取消回调（!=nil时，显示取消按钮）
 *
 *  @return DXLoadingView
 */
+ (instancetype)showWithTitle:(NSString *)title toView:(UIView *)toView cancleCompletion:(void (^)(BOOL didCancle))cancleCompletion;

/**
 *  在页面toView上显示加载
 *
 *  @param title            标题（默认“请稍后...”）
 *  @param toView           显示到哪个页面（==nil时，=[UIApplication sharedApplication].keyWindow）
 *  @param color            主题颜色
 *  @param cancleCompletion 取消回调（!=nil时，显示取消按钮）
 *
 *  @return DXLoadingView
 */
+ (instancetype)showWithTitle:(NSString *)title toView:(UIView *)toView color:(UIColor *)color cancleCompletion:(void (^)(BOOL didCancle))cancleCompletion;
/**
 *  显示加载到[UIApplication sharedApplication].keyWindow上
 *
 *  @param title 标题（默认“请稍后...”）
 *
 *  @return DXLoadingView
 */
+ (instancetype)showWithTitle:(NSString *)title;
/**
 *  在页面toView上显示加载
 *
 *  @param title  标题（默认“请稍后...”）
 *  @param toView 显示到哪个页面（==nil时，=[UIApplication sharedApplication].keyWindow）
 *
 *  @return DXLoadingView
 */
+ (instancetype)showWithTitle:(NSString *)title toView:(UIView *)toView;

/**
 *  移除等待页面
 *
 *  @param forView 移除哪个页面上的（==nil时，=[UIApplication sharedApplication].keyWindow）
 */
+ (void)hideAllForView:(UIView *)forView;

@end
