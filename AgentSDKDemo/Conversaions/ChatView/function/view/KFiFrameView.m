//
//  KFiFrameView.m
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2019/2/13.
//  Copyright © 2019 环信. All rights reserved.
//

#import "KFiFrameView.h"

const NSString *easemobId = @"easemobId";
const NSString *visitorImId = @"visitorImId";

@implementation KFiFrameView {
    KFIframeModel *_model;
}
- (instancetype)initWithFrame:(CGRect)frame
                       iframe:(KFIframeModel * _Nullable)aModel {
    if (self = [super initWithFrame:frame]) {
        _model = aModel;
        [self loadWebView];
    }
    return self;
}

- (void)reloadWebViewFromModel:(KFIframeModel *)aModel
                          user:(UserModel *)aUser {
    if ([_model.url isEqual:aModel.url]) {
        return;
    }
    
    if (!aUser) {
        return;
    }
    _model = aModel;
    _user = aUser;
    
    [self loadWebView];
}

- (void)loadWebView {
    if (!_model.url) {
        return;
    }
    NSString *urlStr = nil;
    if ([_model.url hasPrefix:@"http"]) {
        urlStr = _model.url;
    }else {
        NSString * baseURL = HDClient.sharedClient.option.kefuRestAddress;
        NSString *preStr = [baseURL hasPrefix:@"https"] ? @"https:" : @"http:";
        urlStr = [NSString stringWithFormat:@"%@%@",preStr, _model.url];
    }
    if (_model.encryptAll && _model.encryptKey) {
        _kefuIm = [HDEncryptUtil encryptUseDES:_kefuIm key:_model.encryptKey];
        _visitorInfo = [HDEncryptUtil encryptUseDES:_visitorInfo key:_model.encryptKey];
    }
    
    urlStr = [NSString stringWithFormat:@"%@?easemobId=%@&visitorImId=%@", urlStr, _kefuIm, _visitorInfo];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self loadRequest:request];
}



@end
