//
//  KFWKWebViewController.m
//  AgentSDKDemo
//
//  Created by easemob on 2022/11/14.
//  Copyright © 2022 环信. All rights reserved.
//

#import "KFWKWebViewController.h"
#import "WKWebViewJavascriptBridge.h"
#import "KFiFrameView.h"
@interface KFWKWebViewController ()
{
    NSString *_url;
    NSArray *titleArr;
    NSString *_kefuIm;
    NSString *_visitorInfo;
}
@property WKWebViewJavascriptBridge* bridge;
@property (nonatomic, strong) KFiFrameView *iframeView;
@end

@implementation KFWKWebViewController

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
    
//    if (self.chatBarModel.btnType == KFChatMoreBtnIframeBase) {
//
//        self.title = self.chatBarModel.btnName;
//    }else if(self.chatBarModel.btnType == KFChatMoreBtnIframeRobot){
//
//        self.title = self.chatBarModel.btnName;
//
//    }else{
//
//        self.title = @"iframe";
//
//    }
    self.title = self.iframeModel.iframeTabTitle;
    
    self.navigationItem.leftBarButtonItem = self.backItem;

    [self iframeButtonAction];
    [self.view addSubview:self.iframeView];
   
}

- (void)iframeButtonAction {
    
    __weak typeof(self)weakSelf = self;
    dispatch_block_t block = ^{ @autoreleasepool {
//        KFIframeModel *model = [[HDUserManager sharedInstance] getAgentUserModel].iframeModel;
        
        KFIframeModel *model = self.iframeModel;
        if (model) {
            weakSelf.iframeView.kefuIm = _kefuIm;
            weakSelf.iframeView.visitorInfo = _visitorInfo;
            weakSelf.iframeView.conversation= weakSelf.conversation;
            [weakSelf.iframeView reloadWebViewFromModel:model user:[[HDUserManager sharedInstance] getAgentUserModel]];
        }
    }};
    
    if (!_kefuIm || !_visitorInfo) {
        [self showHudInView:self.view hint:@"获取中..."];
        [HDClient.sharedClient.notiManager asyncFetchVisitorChatInfoWithId:_conversation.chatter.agentId
                                                                completion:^(id info, HDError *error)
        {
            [weakSelf hideHud];
            if (!error) {
                NSArray *kefus = info[@"kefuIms"];
                _kefuIm = kefus.firstObject;
                _visitorInfo = info[@"visitorIm"];
                block();
            }else {
                [weakSelf showHint:@"获取失败..."];
            }
        }];
    }else {
        block();
    }
}

- (KFiFrameView *)iframeView {
    if (!_iframeView) {
        _iframeView = [[KFiFrameView alloc] initWithFrame:self.view.bounds iframe:nil];
//        _iframeView.left = KScreenWidth * 2;
//        _iframeView.backgroundColor = UIColor.redColor;
    }
    return _iframeView;
}

@end
