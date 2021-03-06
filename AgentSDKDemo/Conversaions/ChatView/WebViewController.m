//
//  WebViewController.m
//  EMCSApp
//
//  Created by EaseMob on 15/5/29.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate, UIScrollViewDelegate>
{
    NSString *_url;
}

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation WebViewController

- (instancetype)initWithUrl:(NSString *)url
{
    self = [super init];
    if (self) {
        _url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage imageNamed:@"shai_icon_backCopy"] forState:UIControlStateNormal];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -22, 0, 0);
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.delegate = self;
    [_webView setScalesPageToFit:YES];
    _webView.scrollView.delegate = self;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
    _webView.userInteractionEnabled = YES;
    [self.view addSubview:_webView];
    // Do any additional setup after loading the view.
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //判断是否是单击
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        NSURL *url = [request URL];
        if([[UIApplication sharedApplication]canOpenURL:url])
        {
            [[UIApplication sharedApplication]openURL:url];
        }
        return NO;
    }
    return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *theTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = theTitle;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _webView.scrollView.subviews.firstObject;
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
