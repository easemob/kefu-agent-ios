//
//  ExampleApp-iOS
//
//  Created by Marcus Westin on 1/13/14.
//  Copyright (c) 2014 Marcus Westin. All rights reserved.
//

#import "EMUIWebViewController.h"
#import "WKWebViewJavascriptBridge.h"

@interface EMUIWebViewController ()
{
    NSString *_url;
}
@property WKWebViewJavascriptBridge* bridge;
@property (nonatomic, strong) WKWebView *webView;

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
    
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_webView];
    
    [WKWebViewJavascriptBridge enableLogging];
    
    _bridge = [WKWebViewJavascriptBridge bridgeForWebView:_webView];
    
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



// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

    
    [webView evaluateJavaScript:@"var WVJBIframe = document.createElement('iframe');WVJBIframe.style.display = 'none';WVJBIframe.src = 'wvjbscheme://__BRIDGE_LOADED__';document.documentElement.appendChild(WVJBIframe);setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)" completionHandler:nil];
   
   
    //执行JS方法获取导航栏标题
        [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable title, NSError * _Nullable error) {

            self.title = title;
        }];
}



- (void)loadExamplePage:(WKWebView*)webView {
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
}
@end
