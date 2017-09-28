//
//  KFInputEmailViewController.m
//  EMCSApp
//
//  Created by afanda on 16/11/1.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "KFInputEmailViewController.h"
#import "KFResetPswViewController.h"
#import "Helper.h"

#define kMargin 20
#define kSpace 20

typedef NS_ENUM(NSUInteger, UITextFieldViewTag) {
    UITextFieldViewTagEmail=392,
    UITextFieldViewTagCode,
};
@interface KFInputEmailViewController ()<UITextFieldDelegate,UIAlertViewDelegate>
@property(nonatomic,strong) UIImageView *imageView;
@end

@implementation KFInputEmailViewController
{
    UITextField *_emailField;
    UITextField *_codeField;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView  = [[UIImageView alloc]initWithFrame:CGRectMake(KScreenWidth-kMargin-80,CGRectGetMaxY(_emailField.frame)+kSpace , 80, 35)];
        _imageView.backgroundColor = [UIColor lightGrayColor];
        _imageView.userInteractionEnabled=YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getData)];
        [_imageView addGestureRecognizer:tap];
    }
    return _imageView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"忘记密码";
    [self initUI];
    [self getData];
}

- (void)getData {
    [[HDClient sharedClient] getVerificationImageCompletion:^(id responseObject, HDError *error) {
        if (error == nil) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = responseObject;
                NSString *urlStr = [dic valueForKey:@"url"];
                [_imageView sd_setImageWithURL:[NSURL URLWithString:urlStr]];
                _codeId = [dic valueForKey:@"codeId"];
            }
        }else{
            NSLog(@"获取验证码失败");
            [_imageView sd_setImageWithURL:nil];
        }
    }];
    
}

- (BOOL)testRegisterParametersWithDic:(NSDictionary *)dic {
    if ([[dic valueForKey:@"email"] isEqualToString:@""]) {
        [self showAlertViewWithTitle:@"温馨提示" message:@"邮箱接收验证码,不能为空"];
        return NO;
    }
    if ([_codeField.text isEqualToString:@""]) {
        [self showAlertViewWithTitle:@"温馨提示" message:@"请输入图形验证码，如果没有请点击验证码刷新"];
        return NO;
    }
    if (![Helper isEmail:[dic valueForKey:@"email"]]) {
        [self showAlertViewWithTitle:@"温馨提示" message:@"邮箱格式不正确"];
        return NO;
    }
    return YES;
}

- (void)confirmEmail {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:_codeId forKey:@"codeId"];
    [dic setValue:_emailField.text forKey:@"email"];
    [dic setValue:_codeField.text forKey:@"codeValue"];
    if (![self testRegisterParametersWithDic:dic]) {
        return;
    }
    
    [[HDClient sharedClient] sendVerificationEmailParameters:dic completion:^(id responseObject, HDError *error) {
        //成功
        if (responseObject) {
            KFResetPswViewController *rstVC = [[KFResetPswViewController alloc] init];
            [self.navigationController pushViewController:rstVC animated:YES];
        }else {
            NSLog(@"失败");
            kStrongSelf
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:error.errorDescription delegate:strongSelf cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            
        }
    }];
}

- (void)dealloc {
    NSLog(@"dealloc %s",__func__);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self getData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing];
    return YES;
}

- (void)endEditing {
    [self.view endEditing:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI {
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, KScreenWidth, 20)];
    tip.font = [UIFont systemFontOfSize:18.0];
    tip.textColor = RGBACOLOR(153, 153, 153, 1);
    tip.text = @"请输入您注册的邮箱地址";
    tip.textAlignment = NSTextAlignmentCenter;
    [self.tableView addSubview:tip];
    
    
    _emailField = [UITextField textfieldCreateWithMargin:kMargin originy:CGRectGetMaxY(tip.frame)+kSpace placeHolder:@"邮箱" returnKeyType:UIReturnKeyDone keyboardType:UIKeyboardTypeEmailAddress];
    [self.tableView addSubview:_emailField];
    
    UITextField *codeTf = [UITextField textfieldCreateWithMargin:kMargin originy:CGRectGetMaxY(_emailField.frame)+kSpace placeHolder:@"验证码" returnKeyType:UIReturnKeyDone keyboardType:UIKeyboardTypeDefault];
    codeTf.width = codeTf.width-100;
    [self.tableView addSubview:codeTf];
    codeTf.tag = 10020;
    codeTf.maxCharacterlength = 4;
    [codeTf addSubview:self.imageView];
    _codeField = codeTf;
    
    [self.tableView addSubview:self.imageView];
    
    UIButton *confirmBtn = [UIButton buttonWithMargin:kMargin originY:CGRectGetMaxY(codeTf.frame) + 20 target:self sel:@selector(confirmEmail) title:@"确认"];
    [self.tableView addSubview:confirmBtn];
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
