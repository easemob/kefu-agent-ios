//
//  CommentEditViewController.m
//  EMCSApp
//
//  Created by EaseMob on 16/1/7.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "CommentEditViewController.h"

#define kTextViewPading 11.f
#define kTextViewTop 15.f
#define kTextViewHeight 120.f

@interface CommentEditViewController () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;

@end

@implementation CommentEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑备注";
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self setupBarButtonItem];
    
    self.view.backgroundColor = RGBACOLOR(235, 235, 235, 1);
    
    [self.view addSubview:self.textView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)backAction
{
    [self.textView resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveAction
{
    [self.textView resignFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADD_COMMENT object:[_textView text]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - getter

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
        if (_comment && _comment.length > 0) {
            [_textView setText:_comment];
        }
    }
    return _textView;
}

@end
