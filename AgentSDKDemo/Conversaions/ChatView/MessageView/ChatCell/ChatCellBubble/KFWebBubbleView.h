//
//  KFWebBubbleView.h
//  AgentSDKDemo
//
//  Created by houli on 2022/6/27.
//  Copyright © 2022 环信. All rights reserved.
//

#import "EMChatBaseBubbleView.h"
#import <WebKit/WebKit.h>

typedef void(^ClickIframeCloseBlock)(NSString * content);
@interface KFWebBubbleView : EMChatBaseBubbleView
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UILabel *loadLabel;
@property (nonatomic, copy) ClickIframeCloseBlock clickIframeCloseBlock;

+ (CGFloat)heightForBubbleWithObject:(HDMessage *)object;
- (void)setWebUrl:(NSString *)url;

@end


