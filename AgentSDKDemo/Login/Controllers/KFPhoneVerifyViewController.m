//
//  KFPhoneVerifyViewController.m
//  EMCSApp
//
//  Created by afanda on 16/11/1.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "KFPhoneVerifyViewController.h"
#import "UITextField+KFAdd.h"
#define kMargin 20
#define kSpace 20

typedef NS_ENUM(NSUInteger, RegisterResult) {
    RegisterResultSuccess=3322,
    RegisterResultFailure,
};

@interface KFPhoneVerifyViewController () <UIAlertViewDelegate,UITextFieldDelegate>

@end

@implementation KFPhoneVerifyViewController
{
    UITextField *_phoneNumTF;
    UITextField *_codeTF;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {
    UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, KScreenWidth, 20)];
    tip.font = [UIFont systemFontOfSize:18.0];
    tip.textColor = RGBACOLOR(153, 153, 153, 1);
    tip.text = @"验证码已经发往您的手机(十分钟内有效)";
    tip.textAlignment = NSTextAlignmentCenter;
    [self.tableView addSubview:tip];
    
    _phoneNumTF = [UITextField textfieldCreateWithMargin:kMargin originy:CGRectGetMaxY(tip.frame)+kSpace placeHolder:_phoneNum returnKeyType:UIReturnKeyDone keyboardType:UIKeyboardTypeEmailAddress];
    _phoneNumTF.userInteractionEnabled = NO;
    [self.tableView addSubview:_phoneNumTF];
    
    _codeTF = [UITextField textfieldCreateWithMargin:kMargin originy:CGRectGetMaxY(_phoneNumTF.frame)+kSpace placeHolder:@"验证码" returnKeyType:UIReturnKeyDone keyboardType:UIKeyboardTypeNumberPad];
    _codeTF.maxCharacterlength = 6;
    _codeTF.delegate = self;
    [self.tableView addSubview:_codeTF];
    
    UIButton *confirmBtn = [UIButton buttonWithMargin:kMargin originY:CGRectGetMaxY(_codeTF.frame) + 20 target:self sel:@selector(confirmCode) title:@"确认"];
    [self.tableView addSubview:confirmBtn];
}

- (void)confirmCode {
    [self.view endEditing:YES];
    NSMutableDictionary *dic = [_model dicFromModel];
    [dic setValue:_codeTF.text forKey:@"verifyCode"];
    
    [[HDClient sharedClient] registerUserWithParameters:dic completion:^(id responseObject, HDError *error) {
        if (error == nil) {
            kStrongSelf
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"注册成功" delegate:strongSelf cancelButtonTitle:@"去登陆" otherButtonTitles:nil, nil];
            alert.tag = RegisterResultSuccess;
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:error.errorDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = RegisterResultFailure;
            [alert show];
        }
    }];
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField ==  _codeTF) {
        [self.view endEditing:YES];
    }
    return YES;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == RegisterResultSuccess) {
        [[KFManager sharedInstance] showLoginViewController];
    } else {
        
    }
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
