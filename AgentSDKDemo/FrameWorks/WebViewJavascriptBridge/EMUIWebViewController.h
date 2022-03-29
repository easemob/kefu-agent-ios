//
//  ExampleApp-iOS
//
//  Created by Marcus Westin on 1/13/14.
//  Copyright (c) 2014 Marcus Westin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DXBaseViewController.h"
#import <WebKit/WebKit.h>
@protocol EMUIWebViewControllerDelegate <NSObject>

- (void)clickCustomWebView:(NSDictionary *)data;

@end

@interface EMUIWebViewController : DXBaseViewController <WKUIDelegate>

@property (nonatomic, weak) id<EMUIWebViewControllerDelegate> delegate;

- (instancetype)initWithUrl:(NSString *)url;

@end
