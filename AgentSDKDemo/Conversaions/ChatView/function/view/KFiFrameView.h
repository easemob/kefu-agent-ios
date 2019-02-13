//
//  KFiFrameView.h
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2019/2/13.
//  Copyright © 2019 环信. All rights reserved.
//

#import <WebKit/WebKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface KFiFrameView : WKWebView
@property (nonatomic, strong) UserModel *user;
@property (nonatomic, strong) NSString *kefuIm;
@property (nonatomic, strong) NSString *visitorInfo;
- (instancetype)initWithFrame:(CGRect)frame
                       iframe:(KFIframeModel * _Nullable)aModel;

- (void)reloadWebViewFromModel:(KFIframeModel *)aModel user:(UserModel *)aUser;

@end

NS_ASSUME_NONNULL_END
