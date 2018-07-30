//
//  AuthLoginViewController.m
//  AgentSDKDemo
//
//  Created by xk666 on 2018/7/30.
//  Copyright © 2018年 环信. All rights reserved.
//

#import "AuthLoginViewController.h"
#import <KDAuthSDK/KDAuthManager.h>

#define SINAKDAPPID @"KD120UNFMCJ3SO7ESS"

@interface AuthLoginViewController ()

@end

@implementation AuthLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (IBAction)authLoginAction:(id)sender {
    [[KDAuthManager manager] getKDAuthWithAppid:SINAKDAPPID
                                         userid:nil
                                         params:nil
                                         result:^(BOOL bResult, NSInteger authResult, NSDictionary *dicInfo)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             
             if (bResult && dicInfo)
             {
                 [[HDClient sharedClient] asyncLoginWithEmail:[dicInfo objectForKey:@"email"] completion:^(id responseObject, HDError *error) {
                     if (!error) {
                         [[KFManager sharedInstance] showMainViewController];
                     }
                 }];
                 
             }else{
                 UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:@"授权失败，请重试" preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction *cancel =  [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                 [vc addAction:cancel];
                 [self presentViewController:vc animated:YES completion:nil];
             }
             
         });
     }];
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
