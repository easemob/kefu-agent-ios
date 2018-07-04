//
//  KFSingleRegisterViewController.m
//  EMCSApp
//
//  Created by afanda on 16/11/1.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "KFSingleRegisterViewController.h"
#import "KFPhoneVerifyViewController.h"
#import "UITextField+KFAdd.h"
#define kSpace 20   //横向间隙
#define kMargin 20  //边距


typedef NS_ENUM(NSUInteger, UITextFieldTag) {
    UITextFieldTagEmail = 213,  //邮箱
    UITextFieldTagPsd,          //密码
    UITextFieldTagCfmPsd,       //确认密码
    UITextFieldTagPhoneNum,     //电话号码
    UITextFieldTagCode          //验证码
};

@interface KFSingleRegisterViewController ()<UITextFieldDelegate>
@property(nonatomic,strong) UIImageView *codeImageView;
@property(nonatomic,copy) NSString *codeId;
@end

@implementation KFSingleRegisterViewController
{
    UITextField *_currentTextField;
}
- (UIImageView *)codeImageView {
    if (!_codeImageView) {
        UITextField *tf = [self.tableView viewWithTag:UITextFieldTagPhoneNum];
        _codeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(KScreenWidth-kMargin-80, CGRectGetMaxY(tf.frame)+kSpace, 80, 35)];
        _codeImageView.backgroundColor = [UIColor lightGrayColor];
        _codeImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getData)];
        [_codeImageView addGestureRecognizer:tap];
    }
    return _codeImageView;
}

- (void)getData {
    [[HDClient sharedClient] getVerificationImageCompletion:^(id responseObject, HDError *error) {
        if (error == nil) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = responseObject;
                NSString *urlStr = [dic valueForKey:@"url"];
                [_codeImageView sd_setImageWithURL:[NSURL URLWithString:urlStr]];
                _codeId = [dic valueForKey:@"codeId"];
            }
        }else{
            NSLog(@"获取验证码失败");
            [_codeImageView sd_setImageWithURL:nil];
        }
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self getData];
    [self initNav];
    [self initUI];
}

- (NSMutableDictionary *)getParameters{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSArray *keys = @[@"username",@"password",@"confirmPsw",@"phone",@"codeValue"];
    for (int i=UITextFieldTagEmail; i<=UITextFieldTagCode; i++) {
        UITextField *tf = [self.tableView viewWithTag:i];
        NSString *value = tf.text;
        [dic setValue:value forKey:keys[i-UITextFieldTagEmail]];
    }
    return dic;
}

- (void)initNav {
    self.title = @"个人注册";
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTitle:@"企业" titleColor:[UIColor whiteColor] selectedTitleColor:[UIColor lightGrayColor] target:self action:@selector(companyRegister)];
}

- (void)companyRegister {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initUI {
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat baseSpace = 30;
    NSArray *titles = @[@"邮箱",@"密码",@"确认密码",@"电话号码",@"验证码"];
    for (int i=0; i<=UITextFieldTagCode-UITextFieldTagPsd+1; i++) {
        UIKeyboardType keyboardType=UIKeyboardTypeDefault;
        UIReturnKeyType returnKeyType = UIReturnKeyNext;
        if (i==0) keyboardType = UIKeyboardTypeEmailAddress;
        if (i==3) keyboardType = UIKeyboardTypePhonePad;
        if (i==4) returnKeyType = UIReturnKeyDone;
        
        UITextField *tf = [UITextField textfieldCreateWithMargin:kMargin originy:baseSpace+i*(35+kSpace) placeHolder:titles[i] returnKeyType:returnKeyType keyboardType:keyboardType];
        tf.delegate = self;
        tf.tag = i+UITextFieldTagEmail;
        [self.tableView addSubview:tf];
        
        if (i==1 || i==2) tf.secureTextEntry = YES;
        if (i==3) tf.maxCharacterlength=11;
        if (i==4)  {
            tf.maxCharacterlength=4;
            tf.width = tf.width-100;
        }
    }
    UIButton *submitBtn = [UIButton buttonWithMargin:kMargin originY:CGRectGetMaxY([self.tableView viewWithTag:UITextFieldTagCode].frame)+kSpace target:self sel:@selector(submit) title:@"提交"];
    [self.tableView addSubview:submitBtn];
    [self.tableView addSubview:self.codeImageView];
}

- (void)submit {
    NSMutableDictionary *dic = [self getParameters];
    [dic setValue:@"个人" forKey:@"company"];
    [dic setValue:_codeId forKey:@"codeId"];
    if (![self testRegisterParametersWithDic:dic]) {
        return;
    }
    [self.userModel setValuesForKeysWithDictionary:[dic copy]];
    
    [[HDClient sharedClient] verifyRegisterInfoWithParameters:dic completion:^(id responseObject, HDError *error) {
        if (error == nil) { //成功
            KFPhoneVerifyViewController *phoneVC = [[KFPhoneVerifyViewController alloc] init];
            phoneVC.model = self.userModel;
            UITextField *tf = (UITextField *)[self.tableView viewWithTag:UITextFieldTagPhoneNum];
            phoneVC.phoneNum = tf.text;
            [self.navigationController pushViewController:phoneVC animated:YES];
        }else {//失败
            NSLog(@"%@",error.errorDescription);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error.errorDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (_currentTextField.tag == UITextFieldTagCode) {
        [self.view endEditing:YES];
    }else{
        UITextField *nextTf = [self.tableView viewWithTag:_currentTextField.tag+1];
        [nextTf becomeFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _currentTextField = textField;
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
