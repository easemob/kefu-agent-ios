//
//  KFiFrameView.m
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2019/2/13.
//  Copyright © 2019 环信. All rights reserved.
//

#import "KFiFrameView.h"
#import "WKWebViewJavascriptBridge.h"
#define kDefaultEncryptKey @"11111111"
const NSString *easemobId = @"easemobId";
const NSString *visitorImId = @"visitorImId";

@interface KFiFrameView()
@property WKWebViewJavascriptBridge* bridge;
@end

@implementation KFiFrameView {
    KFIframeModel *_model;
}
- (instancetype)initWithFrame:(CGRect)frame
                       iframe:(KFIframeModel * _Nullable)aModel {
    if (self = [super initWithFrame:frame]) {
        _model = aModel;
        
        [WKWebViewJavascriptBridge enableLogging];

        _bridge = [WKWebViewJavascriptBridge bridgeForWebView:self];

        WEAK_SELF
        [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
            NSLog(@"testObjcCallback called: %@", data);
//            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(clickCustomWebView:)]) {
//                [weakSelf.delegate clickCustomWebView:data];
//            }
            responseCallback(@"Response from testObjcCallback");
        }];

        [_bridge setWebViewDelegate:self];

       

//        _bridge callHandler:<#(NSString *)#> data:<#(id)#> responseCallback:<#^(id responseData)responseCallback#>

        
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
    NSString * par;
    if (_model.encryptAll && _model.encryptKey) {
        
        if ([_model.encryptKey isEqualToString:@""]) {
        
            _model.encryptKey = kDefaultEncryptKey;
        }
        
        _kefuIm = [HDEncryptUtil encryptUseDES:_kefuIm key:_model.encryptKey];
        _visitorInfo = [HDEncryptUtil encryptUseDES:_visitorInfo key:_model.encryptKey];
        
        // 需要加密的其他参数
        par =  [self getParOther:YES];
        
    }else{
        
        par =  [self getParOther:NO];
    }
    
    // 先判断urlStr 内部包含？ 这个字符不 如果包含 我们拼接的时候就不加 如果不包含我们需要添加一下
    
    if ([urlStr containsString:@"?"]) {
        
        urlStr = [NSString stringWithFormat:@"%@&easemobId=%@&visitorImId=%@%@", urlStr, _kefuIm, _visitorInfo,par];
    }else{
        urlStr = [NSString stringWithFormat:@"%@?easemobId=%@&visitorImId=%@&%@", urlStr, _kefuIm, _visitorInfo,par];
        
    }
    
    
    
    NSLog(@"===拼接后的===%@",urlStr);
  
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self loadRequest:request];
}

- (NSString *)encryptUseDES:(NSString *)value{
    
    return [HDEncryptUtil encryptUseDESData:value key:_model.encryptKey];
    
}
-(NSString *)getParOther:(BOOL)isEncryptKey{
    NSString *urlStr = nil;
    VisitorUserModel * visitorModel;
    // 获取访客信息
    if (_conversation.lastMessage) {
        
        HDMessage * message = _conversation.lastMessage;
        
        if ( [HDUtils canObjectForKey:message.nBody.msgExt]) {
            NSDictionary *ext = message.nBody.msgExt;
            @try {
                
                if ([HDUtils canObjectForKey:[ext valueForKey:@"weichat"]] &&[HDUtils canObjectForKey:[ext valueForKey:@"weichat"][@"visitor"]]) {
                    NSDictionary * visitor = [ext valueForKey:@"weichat"][@"visitor"];
                    
                    if (visitor && [visitor isKindOfClass:[NSDictionary class]]) {
                        
                        visitorModel = [[VisitorUserModel alloc] initWithDictionary:visitor];
                    }
                }
                
            } @catch (NSException *exception) {
                [HDLog logE:@"exception:%@",exception];
            } @finally {
                
            }
        }
    }

    //    to=kefuchannelimid_248171&
    NSString*to = _conversation.serviceNumber;
//    nickname=w8du3q187nisgsx&
    NSString*nickname=visitorModel.userNickname;
//    ssid=07938730-2b4b-4f0d-b4ac-45077425898b&
    NSString* ssid=_conversation.sessionId;
//    userId=baa85dce-ef23-4993-b836-6cc437acd320&
    NSString* userId= _conversation.chatter.agentId;
//    email=houli%40163.com&
    NSString* email= _user.username;
//    tenantId=77556&
    NSString* tenantId= _user.tenantId;
//    agentId=fd13ccbd-a712-4e69-9de5-e5e25fec9555&
    NSString* agentId= _user.agentId;
//    agentName=Admin&
    NSString* agentName= _user.nicename;
//    originType=app&
    NSString* originType=_conversation.originType;
    
//    techChannelName=%E4%BE%AF%E5%8A%9B%E5%88%9B%E5%BB%BA%E7%9A%84%E5%85%B3%E8%81%94&
    NSString* techChannelName=_conversation.techChannelName;
//    serviceNumber=kefuchannelimid_248171&
    NSString* serviceNumber=to;
//    desc=&
    NSString* desc= visitorModel.userDescription;
//    trueName=admin
    NSString* trueName=_user.truename;
    
    if (isEncryptKey) {
        to = [self encryptUseDES:to];
        nickname = [self encryptUseDES:nickname];
        ssid = [self encryptUseDES:ssid];
        userId = [self encryptUseDES:userId];
        email = [self encryptUseDES:email];
        tenantId = [self encryptUseDES:tenantId];
        agentId = [self encryptUseDES:agentId];
        agentName = [self encryptUseDES:agentName];
        originType = [self encryptUseDES:originType];
        techChannelName = [self encryptUseDES:techChannelName];
        serviceNumber = [self encryptUseDES:serviceNumber];
        desc = [self encryptUseDES:desc];
        trueName = [self encryptUseDES:trueName];
    }else{

        //需要对value 做一个url 编码
        email =  [email URLEncodedString];
        agentName = [agentName URLEncodedString];
        techChannelName = [techChannelName URLEncodedString];
        desc = [desc URLEncodedString];
        
    }
    
    urlStr = [NSString stringWithFormat:@"to=%@&nickname=%@&ssid=%@&userId=%@&email=%@&tenantId=%@&agentId=f%@&agentName=%@&originType=%@&techChannelName=%@&serviceNumber=%@&desc=%@&trueName=%@", to,nickname,ssid,userId,email,tenantId,agentId,agentName,originType,techChannelName,serviceNumber,desc,trueName];
    
    return urlStr;
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

    [webView evaluateJavaScript:@"var WVJBIframe = document.createElement('iframe');WVJBIframe.style.display = 'none';WVJBIframe.src = 'wvjbscheme://__BRIDGE_LOADED__';document.documentElement.appendChild(WVJBIframe);setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)" completionHandler:nil];
   
}

@end
