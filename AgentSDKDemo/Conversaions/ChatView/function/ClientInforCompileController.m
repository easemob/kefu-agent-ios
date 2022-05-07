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

@property (nonatomic, strong) UITextField *editTextField;

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
    if (_delegate && [_delegate respondsToSelector:@selector(savePatameter:index:)]) {
        [_delegate savePatameter:_editTextField.text index:_type];
    }
}

@end
