//
//  ClientInforCompileController.m
//  EMCSApp
//
//  Created by EaseMob on 15/4/18.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "ClientInforCompileController.h"


@interface ClientInforCompileController ()<UITextFieldDelegate>
{
    int _type;
}

@property (strong ,nonatomic) UITextField *editTextField;

@end

@implementation ClientInforCompileController

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
        if (self.isNumberPad) {
            _editTextField.keyboardType = UIKeyboardTypePhonePad;
        }
        _editTextField.delegate = self;
        _editTextField.backgroundColor = [UIColor whiteColor];
        if (_isPlaceHolder) {
            _editTextField.placeholder = _editContent;
        } else {
            _editTextField.text = _editContent;
        }
        _editTextField.clearButtonMode = YES;
        
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
    if (_delegate && [_delegate respondsToSelector:@selector(savePatameter:index:)]) {
        [_delegate savePatameter:_editTextField.text index:_type];
    }
//    switch (_type) {
//        case 0:
//        {
//            if (_editTextField.text.length > 22) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"客户名最大长度22位" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                [alertView show];
//                return;
//            }
//            [self.delegate saveParameter:_editTextField.text key:USER_NICENAME];
//        }
//            break;
//        case 1:
//        {
//            if (_editTextField.text.length > 22) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"真实姓名最大长度22位" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                [alertView show];
//                return;
//            }
//            [self.delegate saveParameter:_editTextField.text key:USER_TRUENAME];
//        }
//            break;
//        case 2:
//        {
//            NSString *phone = _editTextField.text;
//            NSString *regex = @"[0-9]{11,18}";
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//            BOOL isValid = [predicate evaluateWithObject:phone];
//            if (phone.length > 18 || phone.length < 11) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"手机号为数字有效长度为11-18位" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                [alertView show];
//                return;
//            }
//            if (!isValid) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"正确格式为数字" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                [alertView show];
//                return;
//            }
//            [self.delegate saveParameter:_editTextField.text key:VISTORUSER_PHONE];
//        }
//            break;
//        case 3:
//        {
//            NSString *qq = _editTextField.text;
//            NSString *regex = @"[0-9]{4,22}";
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//            BOOL isValid = [predicate evaluateWithObject:qq];
//            if (qq.length > 22 || qq.length < 4) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"数字有效长度为4-22位" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                [alertView show];
//                return;
//            }
//            if (!isValid) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"正确格式为数字" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                [alertView show];
//                return;
//            }
//            [self.delegate saveParameter:_editTextField.text key:VISTORUSER_QQ];
//        }
//            break;
//        case 4:
//        {
//            NSString *email = _editTextField.text;
//            NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//            BOOL isValid = [predicate evaluateWithObject:email];
//            if (!isValid) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"邮箱为邮箱格式" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                [alertView show];
//                return;
//            }
//            [self.delegate saveParameter:_editTextField.text key:VISTORUSER_EMAIL];
//        }
//            break;
//        case 5:
//        {
//            if (_editTextField.text.length > 24) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"公司最大长度为24位" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                [alertView show];
//                return;
//            }
//            [self.delegate saveParameter:_editTextField.text key:VISTORUSER_COMPANYNAME];
//        }
//            break;
//        case 6:
//        {
//            if (_editTextField.text.length > 100) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"备注最大长度为100位" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                [alertView show];
//                return;
//            }
//            [self.delegate saveParameter:_editTextField.text key:VISTORUSER_DESC];
//        }
//            break;
//        default:
//            break;
//    }
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
