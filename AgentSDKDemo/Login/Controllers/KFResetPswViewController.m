//
//  KFResetPswViewController.m
//  EMCSApp
//
//  Created by afanda on 16/11/1.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "KFResetPswViewController.h"
#import "Helper.h"
#define kMargin 20
#define kSpace 20

#define kConfirmBtnTag 122
typedef NS_ENUM(NSUInteger, UITextFieldTag) {
    UITextFieldTagPsd=1234,
    UITextFieldTagCfmPsd,
    UITextFieldTagCode,
};

typedef NS_ENUM(NSUInteger, UIAlertViewTag) {
    UIAlertViewTagSuccess=322,
    UIAlertViewTagFailure,
};

@interface KFResetPswViewController ()<UIAlertViewDelegate,UITextFieldDelegate>
@end

@implementation KFResetPswViewController
{
    UITextField *_psdTf;
    UITextField *_cfmTf;
    UITextField *_codeTf;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"新密码";
    [self initUI];
}

- (void)initUI {
    self.view.backgroundColor = [UIColor whiteColor];
    //新密码
    _psdTf = [UITextField textfieldCreateWithMargin:kMargin originy:30 placeHolder:@"新密码" returnKeyType:UIReturnKeyNext keyboardType:UIKeyboardTypeDefault];
    _psdTf.secureTextEntry=YES;
    _psdTf.delegate = self;
    _psdTf.tag = UITextFieldTagPsd;
    [self.tableView addSubview:_psdTf];
    
    //确认新密码
    UITextField *cfmTf = [UITextField textfieldCreateWithMargin:kMargin originy:CGRectGetMaxY(_psdTf.frame)+kSpace placeHolder:@"确认新密码" returnKeyType:UIReturnKeyNext keyboardType:UIKeyboardTypeDefault];
    cfmTf.secureTextEntry=YES;
    cfmTf.tag = UITextFieldTagCfmPsd;
    _cfmTf = cfmTf;
    _cfmTf.delegate = self;
    [self.tableView addSubview:cfmTf];
    
    //验证码
    UITextField *codeTf = [UITextField textfieldCreateWithMargin:kMargin originy:CGRectGetMaxY(cfmTf.frame)+kSpace placeHolder:@"邮箱验证码" returnKeyType:UIReturnKeyDone keyboardType:UIKeyboardTypeDefault];
    codeTf.tag = UITextFieldTagCode;
    codeTf.delegate = self;
    _codeTf=codeTf;
    [self.tableView addSubview:codeTf];
    
    UIButton *cfmBtn = [UIButton buttonWithMargin:kMargin originY:CGRectGetMaxY(codeTf.frame)+kSpace target:self sel:@selector(confirmNewPsd) title:@"确认"];
    [self.tableView addSubview:cfmBtn];
}

- (BOOL)testRegisterParametersWithDic:(NSDictionary *)dic {
    NSString *title = @"温馨提示";
    if ([[dic valueForKey:@"password"] isEqualToString:@""]) {
        [self showAlertViewWithTitle:title message:@"请填写新密码"];
        return NO;
    }
    if ([[dic valueForKey:@"confirmPassword"] isEqualToString:@""]) {
        [self showAlertViewWithTitle:title message:@"请确认密码"];
        return NO;
    }
    if ([[dic valueForKey:@"authCode"] isEqualToString:@""]) {
        [self showAlertViewWithTitle:title message:@"请填写邮箱验证码"];
        return NO;
    }
    if (![Helper isPasswordLength:[dic valueForKey:@"password"]]) {
        [self showAlertViewWithTitle:title message:@"密码有效长度应该在6~22位"];
        return NO;
    }
    if (![Helper isPasswordFormat:[dic valueForKey:@"password"]]) {
        [self showAlertViewWithTitle:title message:@"密码至少包含大写字母、小写字母、数字、符号中的两种"];
        return NO;
    }
    if (![[dic valueForKey:@"password"] isEqualToString:[dic valueForKey:@"confirmPassword"]]) {
        [self showAlertViewWithTitle:title message:@"两次输入密码不一致"];
        return NO;
    }
    return YES;
}

- (void)confirmNewPsd {
    [self.view endEditing:YES];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:_psdTf.text forKey:@"password"];
    [dic setValue:_cfmTf.text forKey:@"confirmPassword"];
    [dic setValue:_codeTf.text forKey:@"authCode"];
    
    if (![self testRegisterParametersWithDic:dic]) {
        return;
    }
    [[HDClient sharedClient] resetPasswordWithparameters:dic completion:^(id responseObject, HDError *error) {
        NSString *msg = @"";
        NSString *btnTitle = @"";
        if (responseObject) {
            msg = @"重置密码成功";
            btnTitle = @"去登录";
        }else{
            NSLog(@"失败");
            msg = error.description;
            btnTitle = @"确定";
        }
        kStrongSelf
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:strongSelf cancelButtonTitle:btnTitle otherButtonTitles:nil, nil];
        if (responseObject) {
            alert.tag = UIAlertViewTagSuccess;
        } else {
            alert.tag = UIAlertViewTagFailure;
        }
        [alert show];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == UITextFieldTagCode) {
        [self.view endEditing:YES];
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == UIAlertViewTagSuccess) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"strongSelf-- dealloc -- %s",__func__);
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
