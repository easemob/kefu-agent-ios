//
//  LoginViewController.m
//  EMCSApp
//
//  Created by dhc on 15/4/9.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "DXLoadingView.h"
#import "KFInputEmailViewController.h"
#import "KFCompanyRegisterViewController.h"
#import "UIViewController+DismissKeyboard.h"

#define kLoginMargin 20.f
#define kLoginTextViewHeight 35.f
#define kLogoImageWidth 90
#define kActionViewHeight 240.f

typedef NS_ENUM(NSUInteger, ButtonTag) {
    ButtonTagVisible=1000, //密码可见
    ButtonTagHide,
    ButtonTagFgtPsd, //忘记密码
    ButtonTagLogin,   //登录
};


@interface LoginViewController ()<UITextFieldDelegate>
{
    UIImageView *_logoImageView;
    UIView *_actionView;
    UITextField *_usernameField;
    UITextField *_passwordField;
    UIButton *_inputHideButton;
    UIButton *_hiddenButton;
    UIButton *_fgtPwdButton;
}

@end

@implementation LoginViewController
//注册
- (void)registerUser  {
    KFCompanyRegisterViewController *cmpVC = [[KFCompanyRegisterViewController alloc] init];
    [self.navigationController pushViewController:cmpVC animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登录";
//    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTitle:@"注册" titleColor:[UIColor whiteColor] selectedTitleColor:[UIColor lightGrayColor] target:self action:@selector(registerUser)];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];//RGBACOLOR(28, 36, 46, 1);
    
    _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) - kLogoImageWidth)/2, 75, kLogoImageWidth, kLogoImageWidth)];
    _logoImageView.backgroundColor = [UIColor clearColor];
    _logoImageView.image = [UIImage imageNamed:@"iBestLogo"];
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
    
    _inputHideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _inputHideButton.frame = CGRectMake(CGRectGetMaxX(_passwordField.frame) - 32 * 2, CGRectGetMaxY(_usernameField.frame) + kLoginMargin + 1.5, 32, 32);
    [_inputHideButton setImage:[UIImage imageNamed:@"icon_input_hide"] forState:UIControlStateNormal];
    [_inputHideButton setImage:[UIImage imageNamed:@"icon_input_hide_select"] forState:UIControlStateSelected];
    _inputHideButton.tag = ButtonTagVisible;
    [_inputHideButton addTarget:self action:@selector(inputHideAction:) forControlEvents:UIControlEventTouchUpInside];
    _inputHideButton.hidden = YES;
    [_actionView addSubview:_inputHideButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:_passwordField];
    
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
    _hiddenButton.tag = ButtonTagHide;
    [_actionView addSubview:_hiddenButton];
    
    _fgtPwdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *title = @"忘记密码";
    _fgtPwdButton.tag = ButtonTagFgtPsd;
    [_fgtPwdButton setTitleColor:RGBACOLOR(25, 163, 255, 1) forState:UIControlStateNormal];
    [_fgtPwdButton setTitle:title forState:UIControlStateNormal];
    _fgtPwdButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    CGSize titleSize =  [title sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:_fgtPwdButton.titleLabel.font.fontName size:_fgtPwdButton.titleLabel.font.pointSize]}];
    titleSize.height = 20;
    titleSize.width += 10;
    _fgtPwdButton.origin = CGPointMake(_actionView.width-titleSize.width-20, _hiddenButton.origin.y);
    _fgtPwdButton.size = titleSize;
    [_fgtPwdButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_actionView addSubview:_fgtPwdButton];
    
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(kLoginMargin, CGRectGetMaxY(_hiddenButton.frame) + 10, CGRectGetWidth(_actionView.frame) - kLoginMargin * 2, 45)];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    loginButton.tag = ButtonTagLogin;
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginButton.clipsToBounds = YES;
    loginButton.layer.cornerRadius = 5.f;
    loginButton.titleLabel.font =  [UIFont boldSystemFontOfSize:18.0];
    loginButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [loginButton setBackgroundColor:RGBACOLOR(41, 170, 234, 1)];
    [loginButton addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_actionView addSubview:loginButton];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [self setupForDismissKeyboard];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *loginUserName = [userDefaults objectForKey:USERDEFAULTS_LOGINUSERNAME];
    if (loginUserName && loginUserName.length > 0) {
        _usernameField.text = loginUserName;
        [_passwordField becomeFirstResponder];
    }
}

- (void)buttonClicked:(UIButton *)btn {
    switch (btn.tag) {
        case ButtonTagFgtPsd: //忘记密码
        {
            KFInputEmailViewController *emailVC = [[KFInputEmailViewController alloc] init];
            [self.navigationController pushViewController:emailVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    [textField resignFirstResponder];
    if (textField == _usernameField) {
        [_passwordField becomeFirstResponder];
    } else {
        [self loginButtonAction:nil];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _passwordField) {
        _inputHideButton.hidden = YES;
    }
}

#pragma mark - notification

- (void)textFieldChanged:(NSNotification *)notification
{
    if (_passwordField.text.length > 0) {
        _inputHideButton.hidden = NO;
    } else {
        _inputHideButton.hidden = YES;
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect beginRect = [[userInfo objectForKey:@"UIKeyboardFrameBeginUserInfoKey"] CGRectValue];
    CGRect endRect = [[userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGFloat offset = endRect.origin.y - beginRect.origin.y;
    
    CGRect logoFrame = _logoImageView.frame;
    CGRect actionViewFrame = _actionView.frame;
    //键盘隐藏
    if (offset > 0) {
        logoFrame = CGRectMake((CGRectGetWidth(self.view.frame) - kLogoImageWidth)/2, 75, kLogoImageWidth, kLogoImageWidth);
        actionViewFrame = CGRectMake(kLoginMargin, CGRectGetMaxY(logoFrame) + 20, self.view.frame.size.width - kLoginMargin * 2, kActionViewHeight);
    }
    //键盘显示
    else {
        logoFrame.origin.y = -kLogoImageWidth;
        actionViewFrame.origin.y = 40.f;
    }

    [UIView animateWithDuration:duration animations:^{
        _logoImageView.frame = logoFrame;
        _actionView.frame = actionViewFrame;
    }];
}

#pragma mark - action
- (void)hiddenButtonAction:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    btn.selected = !btn.selected;
}

- (void)loginButtonAction:(id)sender
{
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
    
    WEAK_SELF
    [self showHintNotHide:@"正在登录..."];
    [[HDClient sharedClient] asyncLoginWithUsername:_usernameField.text password:_passwordField.text hidingLogin:_hiddenButton.selected completion:^(id responseObject, HDError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHud];
            if (error == nil) {
                [[KFManager sharedInstance] showMainViewController];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setValue:_usernameField.text forKey:USERDEFAULTS_LOGINUSERNAME];
                [userDefaults synchronize];
            }
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:error.errorDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
        });
    }];
}

- (void)inputHideAction:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        _passwordField.secureTextEntry = NO;
    } else {
        _passwordField.secureTextEntry = YES;
    }
}

@end
