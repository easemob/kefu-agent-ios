//
//  HDSettingViewController.m
//  AgentSDKDemo
//
//  Created by afanda on 4/13/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "HDSettingViewController.h"
#import "AppDelegate.h"

@interface HDSettingViewController ()

@end

@implementation HDSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"设置";
}
- (IBAction)logoutClicked:(id)sender {
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate showLoginViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
