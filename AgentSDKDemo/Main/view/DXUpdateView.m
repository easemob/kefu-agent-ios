//
//  DXUpdateView.m
//  EMCSApp
//
//  Created by EaseMob on 15/9/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "DXUpdateView.h"

@interface DXUpdateView ()
{
    NSDictionary *_info;
}

@end

@implementation DXUpdateView

- (id)initWithFrame:(CGRect)frame updateInfo:(NSDictionary*)info
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupView:info];
    }
    return self;
}

- (void)_setupView:(NSDictionary*)info
{
    _info = info;
    //================appstore start=================
    UIView *bgView = [[UIView alloc] initWithFrame:self.frame];
    bgView.backgroundColor = RGBACOLOR(0x00, 0x00, 0x00, 0.7);
    [self addSubview:bgView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endAction)];
    [bgView addGestureRecognizer:tap];
    
    UIView *contentView =  [[UIView alloc] initWithFrame:CGRectMake(20, 200, KScreenWidth - 40, 44 + 101 + 32 + 48)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 4.f;
    contentView.layer.masksToBounds = YES;
    [self addSubview:contentView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(contentView.frame), 44)];
    label.font = [UIFont systemFontOfSize:16];
    label.text = @"更新新版本";
    label.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:label];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame) - 0.5, CGRectGetWidth(contentView.frame), 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [contentView addSubview:line];
    
    UITextView *textLabel = [[UITextView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame), CGRectGetWidth(contentView.frame), 101 + 32)];
    textLabel.text = [info objectForKey:@"releaseNote"];
    textLabel.textContainerInset = UIEdgeInsetsMake(16, 10, 16, 10);
    textLabel.font = [UIFont systemFontOfSize:14];
    textLabel.textColor = RGBACOLOR(0x09, 0x09, 0x09, 1);
    textLabel.editable = NO;
    [contentView addSubview:textLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, CGRectGetMaxY(textLabel.frame), CGRectGetWidth(contentView.frame), 48);
    [button setTitle:@"立即更新" forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"button_call"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"button_call_select"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(updateAction) forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [contentView addSubview:button];
    //================appstore end=================

}

#pragma mark - action

-(void)endAction
{
    self.hidden = YES;
    [self removeFromSuperview];
}

- (void)updateAction
{
    //================appstore start=================
    NSURL *url = nil;
    url = [NSURL URLWithString:@"http://www.easemob.com/download/app/cs_mobile"];
    [[UIApplication sharedApplication]openURL:url];
    //================appstore end=================
}

@end
