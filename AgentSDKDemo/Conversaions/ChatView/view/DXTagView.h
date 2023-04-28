//
//  DXTagView.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/17.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXTagView : UIView
{
    UIButton *_selectedButton;
    BOOL _flag;
}

@property (nonatomic) BOOL isShow;

@property (nonatomic, strong) UIScrollView *contentView;

@property (nonatomic, copy) NSString *userId;

@property (nonatomic, strong) UIColor *bgColor;

@property (nonatomic, strong) UIView *backgroundView;

- (instancetype)initWithFrame:(CGRect)frame isFromChat:(BOOL)flag;

- (void)loadTag;

@end
