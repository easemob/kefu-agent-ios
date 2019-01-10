//
//  DXLoadingView.m
//  EventRecord
//
//  Created by dhcdht on 14-5-20.
//  Copyright (c) 2014年 XDStudio. All rights reserved.
//

#import "DXLoadingView.h"

@interface DXLoadingView()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *cancleButton;

@end

@implementation DXLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.8];
        _contentColor = [UIColor blackColor];
        
        [self setupSubviews];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setupSubviews
{
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.backgroundColor = [UIColor blackColor];
    _titleLabel.numberOfLines = 0;
    _titleLabel.layer.borderWidth = 2.0;
    _titleLabel.layer.borderColor = [self.contentColor CGColor];
    
    _cancleButton = [[UIButton alloc] init];
    _cancleButton.clipsToBounds = YES;
    [_cancleButton setImage:[UIImage imageNamed:@"cancle"] forState:UIControlStateNormal];
    [_cancleButton setBackgroundColor:self.contentColor];
    [_cancleButton addTarget:self action:@selector(cancleAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.cancleButton];
}

#pragma mark - getter

#pragma mark - setter

- (void)setContentColor:(UIColor *)contentColor
{
    if (contentColor == nil) {
        contentColor = [UIColor blackColor];
    }
    _contentColor = contentColor;
    self.cancleButton.backgroundColor = _contentColor;
}

#pragma mark - private

- (void)cancleAction:(id)sender
{
    [self hide];
    
    if (self.cancleCompletion) {
        self.cancleCompletion(YES);
    }
}

#pragma mark - public

/**
 *  显示到[UIApplication sharedApplication].keyWindow上
 */
- (void)showWithTitle:(NSString *)title
{
    [self showWithTitle:title toView:nil];
}

/**
 *  显示到页面toView上
 *
 *  @param title  标题（默认“请稍后...”）
 *  @param toView 显示到哪个页面
 */
- (void)showWithTitle:(NSString *)title toView:(UIView *)toView
{
    if (toView == nil) {
        toView = [UIApplication sharedApplication].keyWindow;
    }
    self.frame = CGRectMake(0, 0, toView.frame.size.width, toView.frame.size.height);
    
    if (!title || title.length == 0) {
        title = @"请稍后...";
    }
    
    CGFloat maxHeight = 45;
    CGFloat maxWidth = self.frame.size.width - 50;
    if (self.titleLabel.text.length != title.length) {
        CGFloat cancleWidth = 0;
        if (self.cancleCompletion) {
            cancleWidth = maxHeight + 1;
        }
        
        CGSize titleSize = [title boundingRectWithSize:CGSizeMake(maxWidth - cancleWidth, maxHeight)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:self.titleLabel.font}
                                               context:nil].size;
        
        CGFloat titleWidth = titleSize.width == maxWidth ? (titleSize.width + 30) : (titleSize.width + 30);
        
        self.titleLabel.frame = CGRectMake((self.frame.size.width - titleWidth - cancleWidth) / 2, (self.frame.size.height - maxHeight) / 2, titleWidth, maxHeight);
    }
    self.cancleButton.hidden = YES;
    if (self.cancleCompletion) {
        self.cancleButton.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + 1, CGRectGetMinY(self.titleLabel.frame), maxHeight, maxHeight);
        self.cancleButton.hidden = NO;
    }
    self.titleLabel.text = title;
    
    [toView addSubview:self];
}

/**
 *  移除页面
 */
- (void)hide
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - 类方法

/**
 *  显示加载
 *
 *  @param title            标题
 *  @param cancleCompletion 取消回调（!=nil时，显示取消按钮）
 *
 *  @return DXLoadingView
 */
+ (instancetype)showWithTitle:(NSString *)title cancleCompletion:(void (^)(BOOL didCancle))cancleCompletion
{
    return [DXLoadingView showWithTitle:title toView:nil cancleCompletion:cancleCompletion];
}

/**
 *  在页面toView上显示加载
 *
 *  @param title            标题
 *  @param toView           显示到哪个页面
 *  @param cancleCompletion 取消回调（!=nil时，显示取消按钮）
 *
 *  @return DXLoadingView
 */
+ (instancetype)showWithTitle:(NSString *)title toView:(UIView *)toView cancleCompletion:(void (^)(BOOL didCancle))cancleCompletion
{
    DXLoadingView *loadingView = [[DXLoadingView alloc] initWithFrame:CGRectMake(0, 0, toView.frame.size.width, toView.frame.size.height)];
    loadingView.cancleCompletion = cancleCompletion;
    [loadingView showWithTitle:title toView:toView];
    
    return loadingView;
}

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
+ (instancetype)showWithTitle:(NSString *)title toView:(UIView *)toView color:(UIColor *)color cancleCompletion:(void (^)(BOOL didCancle))cancleCompletion
{
    DXLoadingView *loadingView = [[DXLoadingView alloc] initWithFrame:CGRectMake(0, 0, toView.frame.size.width, toView.frame.size.height)];
    loadingView.cancleCompletion = cancleCompletion;
    loadingView.contentColor = color;
    [loadingView showWithTitle:title toView:toView];
    
    return loadingView;
}

/**
 *  显示加载
 *
 *  @param title 标题
 *
 *  @return DXLoadingView
 */
+ (instancetype)showWithTitle:(NSString *)title
{
    return [DXLoadingView showWithTitle:title toView:nil];
}

/**
 *  在页面toView上显示加载
 *
 *  @param title  标题
 *  @param toView 显示到哪个页面
 *
 *  @return DXLoadingView
 */
+ (instancetype)showWithTitle:(NSString *)title toView:(UIView *)toView
{
    DXLoadingView *loadingView = [[DXLoadingView alloc] initWithFrame:CGRectMake(0, 0, toView.frame.size.width, toView.frame.size.height)];
    [loadingView showWithTitle:title toView:toView];
    
    return loadingView;
}

/**
 *  移除等待页面
 *
 *  @param forView 移除哪个页面上的（==nil时，=[UIApplication sharedApplication].keyWindow）
 */
+ (void)hideAllForView:(UIView *)forView
{
    if (forView == nil) {
        forView = [UIApplication sharedApplication].keyWindow;
    }
    
    for (UIView *objectView in forView.subviews) {
        if ([objectView isKindOfClass:[DXLoadingView class]]) {
            [objectView removeFromSuperview];
        }
    }
}

@end
