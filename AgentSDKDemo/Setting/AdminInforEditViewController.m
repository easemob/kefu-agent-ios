//
//  AdminInforEditViewController.m
//  EMCSApp
//
//  Created by EaseMob on 16/1/21.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "AdminInforEditViewController.h"
#import "UITextField+KFAdd.h"

@interface AdminInforEditViewController () <UITextFieldDelegate>
{
    int _type;
}

typedef NS_ENUM(NSUInteger, UITextFieldType) {
    UITextFieldTypeNickname=0,
    UITextFieldTypeName,
    UITextFieldTypeNum,
    UITextFieldTypePhone,
    UITextFieldTypePassword = 5
};

@property (nonatomic, strong) UITextField *editTextField;

@end

@implementation AdminInforEditViewController

- (instancetype)initWithType:(int)type
{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self setupBarButtonItem];
    self.view.backgroundColor = kTableViewBgColor;
    
    [self.view addSubview:self.editTextField];
    switch (_type) {
        case UITextFieldTypeNickname: {
            _editTextField.maxCharacterlength = 22;
             break;
        }
        case UITextFieldTypeName:{
            _editTextField.maxCharacterlength = 24;
            break;
        }
        case UITextFieldTypeNum:{
            _editTextField.maxCharacterlength = 10;
            break;
        }
        case UITextFieldTypePhone:{
            _editTextField.maxCharacterlength = 18;
            break;
        }
        case UITextFieldTypePassword: {
            _editTextField.maxCharacterlength = 22;
            break;
        }
        default:
            break;
    }
}

- (void)setupBarButtonItem
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backButton setImage:[UIImage imageNamed:@"shai_icon_backCopy"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -22, 0, 0);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIButton *dropDownButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [dropDownButton setTitle:@"保存" forState:UIControlStateNormal];
    [dropDownButton setTitleColor:RGBACOLOR(0x1b, 0xa8, 0xed, 1) forState:UIControlStateNormal];
    [dropDownButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:dropDownButton];
}

- (UITextField*)editTextField
{
    if (_editTextField == nil) {
        _editTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 15, KScreenWidth, 50.)];
        _editTextField.returnKeyType = UIReturnKeyDone;
        _editTextField.delegate = self;
        _editTextField.backgroundColor = [UIColor whiteColor];
        _editTextField.text = _editContent;
        _editTextField.clearButtonMode = YES;
        _editTextField.textColor = UIColor.grayColor;
        
        UIView *upline = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 0.5)];
        upline.backgroundColor = [UIColor lightGrayColor];
        [_editTextField addSubview:upline];
        UIView *downline = [[UIView alloc] initWithFrame:CGRectMake(0, _editTextField.height - 0.5, KScreenWidth, 0.5)];
        downline.backgroundColor = [UIColor lightGrayColor];
        [_editTextField addSubview:downline];
        [_editTextField becomeFirstResponder];
    }
    return _editTextField;
}

#pragma mark - UITextFieldDelegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self saveAction];
    return YES;
}

#pragma mark - action
- (void)backAction
{
    [_editTextField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveAction
{
    if (_editTextField.isFirstResponder) {
        [_editTextField resignFirstResponder];
    }
    switch (_type) {
        case 0:
        {
            if (_editTextField.text.length > 22) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"客户名最大长度22位" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
            if ( _editTextField.text.length == 0) {
                kAlert(@"昵称不能为空");
                return;
            }
            [self.delegate saveParameter:_editTextField.text key:USER_NICENAME];
        }
            break;
        case 1:
        {
            if (_editTextField.text.length > 22) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"真实姓名最大长度22位" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
            [self.delegate saveParameter:_editTextField.text key:USER_TRUENAME];
        }
            break;
        case 2:
        {
            NSString *agentNumber = _editTextField.text;
            NSString *regex = @"[0-9]{1,10}";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            BOOL isValid = [predicate evaluateWithObject:agentNumber];
            if (agentNumber.length > 10) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"超长，最大长度 10 位" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
            if (!isValid) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"正确格式为数字" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
            [self.delegate saveParameter:_editTextField.text key:USER_AGENTNUMBER];
        }
            break;
        case 3:
        {
            NSString *phone = _editTextField.text;
            NSString *regex = @"[0-9]{11,18}";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            BOOL isValid = [predicate evaluateWithObject:phone];
            if (phone.length > 18 || phone.length < 11) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"数字有效长度为11-18位" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
            if (!isValid) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"正确格式为数字" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
            [self.delegate saveParameter:_editTextField.text key:USER_PHONE];
        }
            break;
        case 4:
        {
            NSString *email = _editTextField.text;
            NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            BOOL isValid = [predicate evaluateWithObject:email];
            if (!isValid) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"邮箱为邮箱格式" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
            [self.delegate saveParameter:_editTextField.text key:USER_USERNAME];
        }
            break;
        case 5:
        {
            if (_editTextField.text.length > 22) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"密码最大长度为22位" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
            
            if (_editTextField.text.length < 6) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"密码最小长度为6位" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
            [self.delegate saveParameter:_editTextField.text key:@"password"];
        }
            break;
        case 6:
        {
            if (_editTextField.text.length == 0) {
                [self showHint:@"问候语不能为空"];
                return;
            }
            [self.delegate saveParameter:_editTextField.text key:@"content"];
        }
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
