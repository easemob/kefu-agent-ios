//
//  ExampleUIWebViewController.m
//  ExampleApp-iOS
//
//  Created by Marcus Westin on 1/13/14.
//  Copyright (c) 2014 Marcus Westin. All rights reserved.
//

#import "EMUIWebViewController.h"
#import "WebViewJavascriptBridge.h"

@interface EMUIWebViewController ()
{
    NSString *_url;
}
@property WebViewJavascriptBridge* bridge;
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation EMUIWebViewController

- (instancetype)initWithUrl:(NSString *)url
{
    self = [super init];
    if (self) {
        _url = url;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_bridge) { return; }
    
    self.title = @"自定义消息";
    self.navigationItem.leftBarButtonItem = self.backItem;
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_webView];
    
    [WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView];
    
    WEAK_SELF
    [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(clickCustomWebView:)]) {
            [weakSelf.delegate clickCustomWebView:data];
        }
        responseCallback(@"Response from testObjcCallback");
    }];
    
    [_bridge setWebViewDelegate:self];
    
    [_bridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];
    
    [self loadExamplePage:_webView];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView stringByEvaluatingJavaScriptFromString:@"var WVJBIframe = document.createElement('iframe');WVJBIframe.style.display = 'none';WVJBIframe.src = 'wvjbscheme://__BRIDGE_LOADED__';document.documentElement.appendChild(WVJBIframe);setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)"];
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = theTitle;
}

- (void)loadExamplePage:(UIWebView*)webView {
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
}
@end
