//
//  HDMonitorViewController.m
//  AgentSDKDemo
//
//  Created by afanda on 12/4/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "HDMonitorViewController.h"
#import "HomeViewController.h"

@interface HDMonitorViewController ()

@end

@implementation HDMonitorViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupBaseUI];
}

- (void)backAction {
    [[HomeViewController HomeViewController] showLeftView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//private
- (void)setupBaseUI {
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backButton setImage:[UIImage imageNamed:@"shai_icon_backCopy"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -22, 0, 0);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.title = @"现场监控";
    self.view.backgroundColor = kTableViewBgColor;
}

@end
