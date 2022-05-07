//
//  AdminBaseViewController.m
//  EMCSApp
//
//  Created by EaseMob on 16/6/29.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "AdminBaseViewController.h"

#import "EMHeaderImageView.h"

@interface AdminBaseViewController ()

@property (nonatomic, strong) EMHeaderImageView *headerImageView;

@end

@implementation AdminBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kTableViewBgColor;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.headerImageView];
}

#pragma mark - getter

- (EMHeaderImageView*)headerImageView
{
    if (_headerImageView == nil) {
        _headerImageView = [[EMHeaderImageView alloc] init];
        [_headerImageView updateHeadImage];
        _headerImageView.top = 0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backAction)];
        [_headerImageView addGestureRecognizer:tap];
        _headerImageView.userInteractionEnabled = YES;
    }
    return _headerImageView;
}

#pragma mark - action

- (void)backAction
{
    
}

@end
