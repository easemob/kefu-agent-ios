//
//  QuickReplyAddViewController.m
//  EMCSApp
//
//  Created by EaseMob on 15/4/17.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "QuickReplyAddViewController.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"

#define kTextViewPading 11.f
#define kTextViewTop 15.f
#define kTextViewHeight 120.f

@interface QuickReplyAddViewController ()<UITextViewDelegate>

@property (strong, nonatomic) UITextView *textView;

@property (strong, nonatomic) UILabel *numLabel;

@end

@implementation QuickReplyAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self setupBarButtonItem];
    
    self.view.backgroundColor = RGBACOLOR(235, 235, 235, 1);
    
    [self.view addSubview:self.textView];
    [self.view addSubview:self.numLabel];
}

- (void)setupBarButtonItem
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backButton setImage:[UIImage imageNamed:@"shai_icon_backCopy"] forState:UIControlStateNormal];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -22, 0, 0);
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIButton *dropDownButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [dropDownButton setTitle:@"保存" forState:UIControlStateNormal];
    [dropDownButton setTitleColor:RGBACOLOR(0x1b, 0xa8, 0xed, 1) forState:UIControlStateNormal];
    [dropDownButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:dropDownButton];
}

#pragma mark - getter
- (UITextView *)textView
{
    if (_textView == nil) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, kTextViewTop, KScreenWidth, kTextViewHeight)];
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.delegate = self;
        _textView.layer.borderWidth = 0.5;
        _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.font = [UIFont systemFontOfSize:16];
        _textView.textColor = RGBACOLOR(0x09, 0x09, 0x09, 1);
        _textView.textContainerInset = UIEdgeInsetsMake(kTextViewPading/2, kTextViewPading, kTextViewPading/2, kTextViewPading);
        if (_qrMsgModel) {
            self.numLabel.text = [NSString stringWithFormat:@"%@",@(400 - _textView.text.length)];
            [_textView becomeFirstResponder];
        }
    }
    return _textView;
}

- (UILabel *)numLabel
{
    if (_numLabel == nil) {
        _numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_textView.frame) - 35, KScreenWidth - 5, 30.0)];
        _numLabel.text = @"400";
        _numLabel.textColor = RGBACOLOR(0x9b, 0x9b, 0x9b, 1);
        _numLabel.textAlignment = NSTextAlignmentRight;
        _numLabel.font = [UIFont systemFontOfSize:15];
        if (_qrMsgModel) {
            _textView.text = _qrMsgModel.phrase;
        }
    }
    return _numLabel;
}

#pragma mark - action
- (void)backAction
{
    [_textView resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveAction
{
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
    }
    if (self.textView.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"快捷回复内容不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        if (_qrMsgModel) {
            _qrMsgModel.phrase = self.textView.text;
            [self showHintNotHide:@"修改中..."];
            WEAK_SELF
            [[HDClient sharedClient].chatManager updateQuickReplyWithParentId:self.parentId text:self.textView.text leaf:_qrMsgModel.leaf qrId:_qrMsgModel.Id completion:^(id responseObject, HDError *error) {
                [weakSelf hideHud];
                if (!error) {
                    if ([weakSelf.delegate respondsToSelector:@selector(addQuickReplyMessage:)]) {
                        [weakSelf.delegate addQuickReplyMessage:nil];
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                    [weakSelf showHint:@"修改成功"];
                    [weakSelf hideHud];
                } else{
                    [weakSelf showHint:@"修改失败"];
                    [weakSelf hideHud];
                }
            }];
        } else {
            [self showHintNotHide:@"新增中..."];
            WEAK_SELF
            [[HDClient sharedClient].chatManager addQuickReplyWithParentId:self.parentId text:self.textView.text leaf:self.leaf completion:^(id responseObject, HDError *error) {
                [weakSelf hideHud];
                if (!error) {
                    @try {
                        if (responseObject) {
                            QuickReplyMessageModel *qrMsgModel = [[QuickReplyMessageModel alloc] initWithDictionary:responseObject];
                            if ([weakSelf.delegate respondsToSelector:@selector(addQuickReplyMessage:)]) {
                                [weakSelf.delegate addQuickReplyMessage:qrMsgModel];
                                [weakSelf.navigationController popViewControllerAnimated:YES];
                            }
                        }
                    } @catch (NSException *exception) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    [weakSelf showHint:@"修改成功"];
                } else{
                    [weakSelf showHint:@"修改失败"];
                }
            }];
            
        }
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    self.numLabel.text = [NSString stringWithFormat:@"%@",@(400 - textView.text.length)];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
#define MY_MAX 400
    if ((textView.text.length - range.length + text.length) > MY_MAX) {
        NSString *substring = [text substringToIndex:MY_MAX - (textView.text.length - range.length)];
        NSMutableString *lastString = [textView.text mutableCopy];
        [lastString replaceCharactersInRange:range withString:substring];
        textView.text = [lastString copy];
        return NO;
    } else {
        return YES;
    }
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
