//
//  EMEditViewController.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/9.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMEditViewController.h"

@interface EMEditViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *editTextField;

@end

@implementation EMEditViewController

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
        _editTextField.delegate = self;
        _editTextField.backgroundColor = [UIColor whiteColor];
        _editTextField.layer.borderWidth = 0.5;
        _editTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _editTextField.clearButtonMode = YES;
        
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(saveParameter:key:)]) {
        [self.delegate saveParameter:[_editTextField text] key:_key];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
