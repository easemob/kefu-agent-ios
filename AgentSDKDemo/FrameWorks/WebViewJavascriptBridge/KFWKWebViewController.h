//
//  KFWKWebViewController.h
//  AgentSDKDemo
//
//  Created by easemob on 2022/11/14.
//  Copyright © 2022 环信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXBaseViewController.h"
#import "KFChatBarMoreModel.h"
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

@protocol KFWKWebViewControllerDelegate <NSObject>

- (void)clickCustomWebView:(NSDictionary *)data;

@end
@interface KFWKWebViewController : DXBaseViewController <WKUIDelegate>

@property (nonatomic, weak) id<KFWKWebViewControllerDelegate> delegate;
@property (nonatomic, strong) HDConversation *conversation;
@property (nonatomic, copy) NSString *visitorId;
@property (nonatomic, strong) KFChatBarMoreModel *chatBarModel;
- (instancetype)initWithUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
