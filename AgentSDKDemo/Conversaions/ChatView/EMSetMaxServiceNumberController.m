//
//  EMSetMaxServiceNumberController.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/4.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMSetMaxServiceNumberController.h"
#import "SBTickerView.h"
#define kLeftMaxNum 1
#define kLeftMinNum 0

#define kMiddleMaxNum 9
#define kMiddleMinNum 0

#define kRightMaxNum 9
#define kRightMinNum 0

#define kNumberWidth 78

@interface EMSetMaxServiceNumberController ()
{
    NSMutableArray *_serviceUsersNum;
    int _leftCount;
    int _middleCount;
    int _rightCount;
}

@property (nonatomic, strong) UIBarButtonItem *saveItem;
@property (nonatomic, strong) UILabel *leftNumberLabel;
@property (nonatomic, strong) UILabel *middleNumberLabel;
@property (nonatomic, strong) UILabel *rightNumberLabel;

@property (nonatomic, strong) UIView *leftBgView;
@property (nonatomic, strong) UIView *middleBgView;
@property (nonatomic, strong) UIView *rightBgView;

@property (nonatomic, strong) SBTickerView *leftTickerView;
@property (nonatomic, strong) SBTickerView *middleTickerView;
@property (nonatomic, strong) SBTickerView *rightTickerView;

@property (nonatomic, strong) UIButton *leftUpButton;
@property (nonatomic, strong) UIButton *leftDownButton;

@property (nonatomic, strong) UIButton *middleUpButton;
@property (nonatomic, strong) UIButton *middleDownButton;

@property (nonatomic, strong) UIButton *rightUpButton;
@property (nonatomic, strong) UIButton *rightDownButton;

@end

@implementation EMSetMaxServiceNumberController
{
    UserModel *_user;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _user = [HDClient sharedClient].currentAgentUser;
    self.title = @"最大接待人数";
    self.navigationItem.leftBarButtonItem = self.backItem;
    self.navigationItem.rightBarButtonItem = self.saveItem;
    self.tableView.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    int max = (int)_user.maxServiceSessionCount;
    _leftCount = max/100;
    _middleCount = max%100/10;
    _rightCount = max%10;
    
    [self.view addSubview:self.leftBgView];
    [self.view addSubview:self.middleBgView];
    [self.view addSubview:self.rightBgView];
}

- (UIView *)leftBgView
{
    if (_leftBgView == nil) {
        _leftBgView = [[UIView alloc] initWithFrame:CGRectMake((KScreenWidth-3*(kNumberWidth+20)-20)/2, 50, kNumberWidth + 20, 198)];
        _leftBgView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _leftBgView.layer.borderWidth = 0.5f;
        [_leftBgView addSubview:self.leftTickerView];
        [_leftBgView addSubview:self.leftUpButton];
        [_leftBgView addSubview:self.leftDownButton];
    }
    return _leftBgView;
}

- (UIView *)middleBgView {
    if (_middleBgView == nil) {
        _middleBgView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.leftBgView.frame)+10, 50, kNumberWidth + 20, 198)];
        _middleBgView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _middleBgView.layer.borderWidth = 0.5f;
        [_middleBgView addSubview:self.middleTickerView];
        [_middleBgView addSubview:self.middleUpButton];
        [_middleBgView addSubview:self.middleDownButton];
    }
    return _middleBgView;
}

- (UIView *)rightBgView
{
    if (_rightBgView == nil) {
        _rightBgView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.middleBgView.frame)+10, 50, kNumberWidth + 20, 198)];
        _rightBgView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _rightBgView.layer.borderWidth = 0.5f;
        [_rightBgView addSubview:self.rightTickerView];
        [_rightBgView addSubview:self.rightUpButton];
        [_rightBgView addSubview:self.rightDownButton];
    }
    return _rightBgView;
}

- (UIButton *)rightDownButton
{
    if (_rightDownButton == nil) {
        _rightDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightDownButton.frame = CGRectMake(self.rightTickerView.left, CGRectGetMaxY(self.rightTickerView.frame), self.rightTickerView.width, 27);
        [_rightDownButton setImage:[UIImage imageNamed:@"info_expand_icon_push"] forState:UIControlStateNormal];
        [_rightDownButton addTarget:self action:@selector(downRightAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightDownButton;
}

- (UIButton *)rightUpButton
{
    if (_rightUpButton == nil) {
        _rightUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightUpButton.frame = CGRectMake(self.rightTickerView.left, CGRectGetMinY(self.rightTickerView.frame) - 27, self.rightTickerView.width, 27);
        [_rightUpButton setImage:[UIImage imageNamed:@"info_expand_icon_pull"] forState:UIControlStateNormal];
        [_rightUpButton addTarget:self action:@selector(upRightAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightUpButton;
}

- (UIButton *)leftDownButton
{
    if (_leftDownButton == nil) {
        _leftDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftDownButton.frame = CGRectMake(self.leftTickerView.left, CGRectGetMaxY(self.leftTickerView.frame), self.leftTickerView.width, 27);
        [_leftDownButton setImage:[UIImage imageNamed:@"info_expand_icon_push"] forState:UIControlStateNormal];
        [_leftDownButton addTarget:self action:@selector(downAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftDownButton;
}

- (UIButton *)leftUpButton
{
    if (_leftUpButton == nil) {
        _leftUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftUpButton.frame = CGRectMake(self.leftTickerView.left, CGRectGetMinY(self.leftTickerView.frame) - 27, self.leftTickerView.width, 27);
        [_leftUpButton setImage:[UIImage imageNamed:@"info_expand_icon_pull"] forState:UIControlStateNormal];
        [_leftUpButton addTarget:self action:@selector(upAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftUpButton;
}

- (UIButton *)middleUpButton {
    if (_middleUpButton == nil) {
        _middleUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _middleUpButton.frame = CGRectMake(self.middleTickerView.left, CGRectGetMinY(self.middleTickerView.frame) - 27, self.middleTickerView.width, 27);
        [_middleUpButton setImage:[UIImage imageNamed:@"info_expand_icon_pull"] forState:UIControlStateNormal];
        [_middleUpButton addTarget:self action:@selector(upMiddleAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _middleUpButton;
}

- (UIButton *)middleDownButton {
    if (_middleDownButton == nil) {
        _middleDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _middleDownButton.frame = CGRectMake(self.middleTickerView.left, CGRectGetMaxY(self.middleTickerView.frame), self.middleTickerView.width, 27);
        [_middleDownButton setImage:[UIImage imageNamed:@"info_expand_icon_push"] forState:UIControlStateNormal];
        [_middleDownButton addTarget:self action:@selector(downMiddleAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _middleDownButton;
}

- (SBTickerView*)leftTickerView
{
    if (_leftTickerView == nil) {
        _leftTickerView = [[SBTickerView alloc] initWithFrame:CGRectMake(10, 27, kNumberWidth, 144)];
        [_leftTickerView setFrontView:self.leftNumberLabel];
        [_leftTickerView setBackView:self.leftNumberLabel];
    }
    return _leftTickerView;
}

-(SBTickerView *)middleTickerView {
    if (_middleTickerView == nil) {
        _middleTickerView = [[SBTickerView alloc] initWithFrame:CGRectMake(10, 27, kNumberWidth, 144)];
        [_middleTickerView setFrontView:self.middleNumberLabel];
        [_middleTickerView setBackView:self.middleNumberLabel];
    }
    return _middleTickerView;
}

- (SBTickerView*)rightTickerView
{
    if (_rightTickerView == nil) {
        _rightTickerView = [[SBTickerView alloc] initWithFrame:CGRectMake(10, 27, kNumberWidth, 144)];
        [_rightTickerView setFrontView:self.rightNumberLabel];
        [_rightTickerView setBackView:self.rightNumberLabel];
    }
    return _rightTickerView;
}

- (UILabel*)rightNumberLabel
{
    if (_rightNumberLabel == nil) {
        _rightNumberLabel = [[UILabel alloc] init];
        _rightNumberLabel.frame = CGRectMake(0, 0, kNumberWidth, 144);
        _rightNumberLabel.textColor = [UIColor blackColor];
        _rightNumberLabel.textAlignment = NSTextAlignmentCenter;
        _rightNumberLabel.font = [UIFont systemFontOfSize:135];
        _rightNumberLabel.text = [NSString stringWithFormat:@"%d",_rightCount];
        _rightNumberLabel.backgroundColor = [UIColor whiteColor];
    }
    return _rightNumberLabel;
}

- (UILabel *)middleNumberLabel {
    if (_middleNumberLabel == nil) {
        _middleNumberLabel = [[UILabel alloc] init];
        _middleNumberLabel.frame = CGRectMake(0, 0, kNumberWidth, 144);
        _middleNumberLabel.textColor = [UIColor blackColor];
        _middleNumberLabel.textAlignment = NSTextAlignmentCenter;
        _middleNumberLabel.font = [UIFont systemFontOfSize:135];
        
        _middleNumberLabel.text = [NSString stringWithFormat:@"%d",_middleCount];
        _middleNumberLabel.backgroundColor = [UIColor whiteColor];
    }
    return _middleNumberLabel;
}

- (UILabel*)leftNumberLabel
{
    if (_leftNumberLabel == nil) {
        _leftNumberLabel = [[UILabel alloc] init];
        _leftNumberLabel.frame = CGRectMake(0, 0, kNumberWidth, 144);
        _leftNumberLabel.textColor = [UIColor blackColor];
        _leftNumberLabel.textAlignment = NSTextAlignmentCenter;
        _leftNumberLabel.font = [UIFont systemFontOfSize:135];

        _leftNumberLabel.text = [NSString stringWithFormat:@"%d",_leftCount];
        _leftNumberLabel.backgroundColor = [UIColor whiteColor];
    }
    return _leftNumberLabel;
}

- (UIBarButtonItem*)saveItem
{
    if (_saveItem == nil) {
        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        saveButton.frame = CGRectMake(0, 0, 44, 44);
        [saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
        _saveItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    }
    return _saveItem;
}

#pragma - mark Action

- (void)upAction
{
    if (_leftCount == kLeftMaxNum) {
        _leftCount = kLeftMinNum - 1;
    }
    _leftNumberLabel.text = [NSString stringWithFormat:@"%d",++_leftCount];
    
    if (_leftCount == kLeftMaxNum) {
        _middleCount = kMiddleMinNum;
        _rightCount = kRightMinNum;
        _middleNumberLabel.text = [NSString stringWithFormat:@"%d",_middleCount];
        _rightNumberLabel.text = [NSString stringWithFormat:@"%d",_rightCount];
    }
    [_leftTickerView setFrontView:_leftNumberLabel];
    [_leftTickerView tick:SBTickerViewTickDirectionUp animated:YES completion:nil];
}

- (void)downAction
{
    if (_leftCount == kLeftMinNum) {
        _leftCount = kLeftMaxNum + 1;
    }
    _leftNumberLabel.text = [NSString stringWithFormat:@"%d",--_leftCount];
    if (_leftCount == kLeftMaxNum) {
        _middleCount = kMiddleMinNum;
        _rightCount = kRightMinNum;
        _middleNumberLabel.text = [NSString stringWithFormat:@"%d",_middleCount];
        _rightNumberLabel.text = [NSString stringWithFormat:@"%d",_rightCount];
    }
    [_leftTickerView setBackView:_leftNumberLabel];
    [_leftTickerView tick:SBTickerViewTickDirectionDown animated:YES completion:nil];
}

- (void)upMiddleAction {
    if (_leftCount == kLeftMaxNum) {
        return;
    }
    if (_middleCount == kMiddleMaxNum) {
        _middleCount = kMiddleMinNum - 1;
    }
    _middleNumberLabel.text = [NSString stringWithFormat:@"%d",++_middleCount];
    [_middleTickerView setBackView:_middleNumberLabel];
    [_middleTickerView tick:SBTickerViewTickDirectionUp animated:YES completion:nil];
}

- (void)downMiddleAction {
    if (_leftCount == kLeftMaxNum) {
        return;
    }
    if (_middleCount == kRightMinNum) {
        _middleCount = kRightMaxNum + 1;
    }
    _middleNumberLabel.text = [NSString stringWithFormat:@"%d",--_middleCount];
    [_middleTickerView setFrontView:_middleNumberLabel];
    [_middleTickerView tick:SBTickerViewTickDirectionDown animated:YES completion:nil];
}

- (void)upRightAction
{
    if (_leftCount == kLeftMaxNum) {
        return;
    }
    if (_rightCount == kRightMaxNum) {
        _rightCount = kRightMinNum - 1;
    }
    _rightNumberLabel.text = [NSString stringWithFormat:@"%d",++_rightCount];
    [_rightTickerView setBackView:_rightNumberLabel];
    [_rightTickerView tick:SBTickerViewTickDirectionUp animated:YES completion:nil];
}

- (void)downRightAction
{
    if (_leftCount == kLeftMaxNum) {
        return;
    }
    if (_rightCount == kRightMinNum) {
        _rightCount = kRightMaxNum + 1;
    }
    _rightNumberLabel.text = [NSString stringWithFormat:@"%d",--_rightCount];
    [_rightTickerView setFrontView:_rightNumberLabel];
    [_rightTickerView tick:SBTickerViewTickDirectionDown animated:YES completion:nil];
}

- (void)saveAction
{
    //agent指的是agent; admin,agent  指的是admin 【roles】;
    if (!_user.allowAgentChangeMaxSessions && ![_user.roles containsString:@"admin"]) {
        [MBProgressHUD showMessag:@"管理员不允许设置最大接入数" toView:nil];
        return;
    }
    
    NSString *value = [NSString stringWithFormat:@"%d",_leftCount * 100 + _middleCount * 10 + _rightCount];
    if (_user.maxServiceSessionCount != [value integerValue]) {
        [self showHintNotHide:@"修改用户最大接入数..."];
        WEAK_SELF
        [[HDClient sharedClient].setManager updateServiceUsersWithNum:value completion:^(id responseObject, HDError *error) {
            [weakSelf hideHud];
            if (!error) {
                hd_dispatch_main_async_safe(^(){
                    [weakSelf.tableView reloadData];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SET_MAX_SERVICECOUNT object:nil];
                    if ([value integerValue] == 0) {
                        [weakSelf showHint:@"已关闭自动接入"];
                    } else {
                        [weakSelf showHint:@"修改成功"];
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                });
            } else {
                [weakSelf showHint:@"修改失败"];
            }

        }];
    }
}

@end
