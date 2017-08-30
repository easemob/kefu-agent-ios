//
//  HDLoginViewController.m
//  AgentSDKDemo
//
//  Created by afanda on 4/13/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "HDLoginViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"


#define kLoginMargin 20.f
#define kLoginTextViewHeight 35.f
#define kLogoImageWidth 90
#define kActionViewHeight 240.f
@interface HDLoginViewController ()<UITextFieldDelegate>

@end

@implementation HDLoginViewController
{
    UIImageView *_logoImageView;
    UIView *_actionView;
    UITextField *_usernameField;
    UITextField *_passwordField;
    UIButton *_inputHideButton;
    UIButton *_hiddenButton;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"登录";
    [self initUI];
}

- (void)initUI {
     self.view.backgroundColor = [UIColor whiteColor];
    _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) - kLogoImageWidth)/2, 75, kLogoImageWidth, kLogoImageWidth)];
    _logoImageView.backgroundColor = [UIColor clearColor];
    _logoImageView.image = [UIImage imageNamed:@"icon_180"];
    _logoImageView.layer.masksToBounds = YES;
    _logoImageView.layer.cornerRadius = kLogoImageWidth/2;
    [self.view addSubview:_logoImageView];
    _actionView = [[UIView alloc] initWithFrame:CGRectMake(kLoginMargin, CGRectGetMaxY(_logoImageView.frame) + 43, self.view.frame.size.width - kLoginMargin * 2, kActionViewHeight)];
    _actionView.backgroundColor = [UIColor whiteColor];
    _actionView.layer.cornerRadius = 5.f;
    [self.view addSubview:_actionView];
    
    _usernameField = [[UITextField alloc] initWithFrame:CGRectMake(kLoginMargin, kLoginMargin, CGRectGetWidth(_actionView.frame) - kLoginMargin * 2, kLoginTextViewHeight)];
    _usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"账号" attributes:@{NSForegroundColorAttributeName:RGBACOLOR(0x99, 0x99, 0x99, 1)}];
    _usernameField.font = [UIFont systemFontOfSize:16.0];
    _usernameField.text = [StandardUserDefaults valueForKey:DefaultUsername];
    _usernameField.clipsToBounds = YES;
    _usernameField.backgroundColor = [UIColor whiteColor];
    _usernameField.textAlignment = NSTextAlignmentLeft;
    _usernameField.textColor = RGBACOLOR(0x1a, 0x1a, 0x1a, 1);
    _usernameField.font = [UIFont systemFontOfSize:16];
    _usernameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _usernameField.returnKeyType = UIReturnKeyNext;
    _usernameField.keyboardType = UIKeyboardTypeEmailAddress;
    _usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    _usernameField.delegate = self;
    [_actionView addSubview:_usernameField];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(kLoginMargin, CGRectGetMaxY(_usernameField.frame) - 1.f, CGRectGetWidth(_usernameField.frame), 1.f)];
    line.backgroundColor = RGBACOLOR(0xe5, 0xe5, 0xe5, 1);
    [_actionView addSubview:line];
    
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(kLoginMargin, CGRectGetMaxY(_usernameField.frame) + kLoginMargin, CGRectGetWidth(_actionView.frame) - kLoginMargin * 2, kLoginTextViewHeight)];
    _passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"密码" attributes:@{NSForegroundColorAttributeName:RGBACOLOR(0x99, 0x99, 0x99, 1)}];
    _passwordField.font = [UIFont systemFontOfSize:16.0];
    _passwordField.clipsToBounds = YES;
    _passwordField.backgroundColor = [UIColor whiteColor];
    _passwordField.textAlignment = NSTextAlignmentLeft;
    _passwordField.textColor = RGBACOLOR(0x1a, 0x1a, 0x1a, 1);
    _passwordField.font = [UIFont systemFontOfSize:16];
    _passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passwordField.returnKeyType = UIReturnKeyDone;
    _passwordField.secureTextEntry = YES;
    _passwordField.delegate = self;
    [_actionView addSubview:_passwordField];
    
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(kLoginMargin, CGRectGetMaxY(_passwordField.frame) - 1.f, CGRectGetWidth(_passwordField.frame), 1.f)];
    line2.backgroundColor = RGBACOLOR(0xe5, 0xe5, 0xe5, 1);
    [_actionView addSubview:line2];
    
    _hiddenButton = [[UIButton alloc] initWithFrame:CGRectMake(kLoginMargin, CGRectGetMaxY(_passwordField.frame) + 15, 22 + 100, 22)];
    [_hiddenButton setTitle:@"隐身登录" forState:UIControlStateNormal];
    [_hiddenButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _hiddenButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [_hiddenButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 22, 0, 0)];
    [_hiddenButton setImage:[UIImage imageNamed:@"icon_mono_off"] forState:UIControlStateNormal];
    [_hiddenButton setImage:[UIImage imageNamed:@"icon_mono_on"] forState:UIControlStateSelected];
    [_hiddenButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 100)];
    [_hiddenButton addTarget:self action:@selector(hiddenButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_actionView addSubview:_hiddenButton];
    
    
    
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(kLoginMargin, CGRectGetMaxY(_hiddenButton.frame) + 10, CGRectGetWidth(_actionView.frame) - kLoginMargin * 2, 45)];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginButton.clipsToBounds = YES;
    loginButton.layer.cornerRadius = 5.f;
    loginButton.titleLabel.font =  [UIFont boldSystemFontOfSize:18.0];
    loginButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [loginButton setBackgroundColor:RGBACOLOR(41, 170, 234, 1)];
    [loginButton addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_actionView addSubview:loginButton];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *loginUserName = [userDefaults objectForKey:@"username"];
    if (loginUserName && loginUserName.length > 0) {
        _usernameField.text = loginUserName;
        [_passwordField becomeFirstResponder];
    }
    
    //进入登陆页面进行解绑操作,一直到解绑成功
//    [[KefuUnbindManager shareManager] unbindDeviceToken];
}

- (void)hiddenButtonAction:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    btn.selected = !btn.selected;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _usernameField) {
        [_passwordField becomeFirstResponder];
    } else {
        [self loginButtonAction:nil];
    }
    return YES;
}

- (void)loginButtonAction:(id)sender
{
    
    [StandardUserDefaults setValue:_usernameField.text forKey:DefaultUsername];
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];

    WEAK_SELF
    [self showHintNotHide:@"正在登录..."];
    [[HDNetworkManager sharedInstance] asyncLoginWithUsername:_usernameField.text password:_passwordField.text hidingLogin:_hiddenButton.selected completion:^(id responseObject, HDError *error) {
        [weakSelf hideHud];
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:error.errorDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            HDManager *manager  = [HDManager shareInstance];
            [manager showMainViewController];
        }
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _passwordField) {
        _inputHideButton.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"%s dealloc",__func__);
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
