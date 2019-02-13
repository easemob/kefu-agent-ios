//
//  DXTagView.m
//  EMCSApp
//
//  Created by EaseMob on 15/4/17.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "DXTagView.h"
#import "UserTagModel.h"
#import "EMClientInfoTagView.h"

@interface DXTagView ()

@property (nonatomic, strong) NSMutableArray *tagSource;

@end

@implementation DXTagView

- (instancetype)initWithFrame:(CGRect)frame isFromChat:(BOOL)flag
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isShow = NO;
        _backgroundView = [[UIView alloc] initWithFrame:frame];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        [self addSubview:_backgroundView];
        _flag = flag;
    }
    return self;
}

#pragma mark - layout

- (void)setBgColor:(UIColor *)bgColor
{
    _backgroundView.backgroundColor = _bgColor;
}

- (void)setupOnProfileSubviews
{
    _contentView = [[UIScrollView alloc] init];
    _contentView.contentSize = CGSizeMake(self.frame.size.width, 200);
    _contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_contentView];
    
    _contentView.frame = CGRectMake(0, 0, self.width, self.height);
    float marginY = 15;
    
    CGFloat left = 0;
    CGFloat top = 10;
    for (HDUserTag *model in _tagSource) {
        left +=10.f;
        EMClientInfoTagView *tagView = [[EMClientInfoTagView alloc] initWithUserTagModel:model visitorUserId:_userId];
        if (left + tagView.width> KScreenWidth - 10) {
            left = 10;
            top += tagView.height + 10;
            marginY = top + tagView.height;
        }
        tagView.left = left;
        tagView.top = top;
        left += tagView.width;
        [_contentView addSubview:tagView];
    }

    _contentView.contentSize = CGSizeMake(self.frame.size.width, marginY);
}


- (void)loadTag
{
    [[HDClient sharedClient].setManager getVisitorUserTagsWithUserId:_userId completion:^(id responseObject, HDError *error) {
        if (error == nil) {
            _tagSource = responseObject;
            if (_flag) {
                //[self setupOnChatSubviews];
            } else {
                [self setupOnProfileSubviews];
            }
            if ([_tagSource count] == 0 && self.isShow) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"暂时没有相关标签" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
    }];

}

@end
