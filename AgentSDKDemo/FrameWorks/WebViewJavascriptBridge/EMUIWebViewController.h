//
//  ExampleUIWebViewController.h
//  ExampleApp-iOS
//
//  Created by Marcus Westin on 1/13/14.
//  Copyright (c) 2014 Marcus Westin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DXBaseViewController.h"

@protocol EMUIWebViewControllerDelegate <NSObject>

- (void)clickCustomWebView:(NSDictionary*)data;

@end

@interface EMUIWebViewController : DXBaseViewController <UIWebViewDelegate>

@property (nonatomic, weak) id<EMUIWebViewControllerDelegate> delegate;

- (instancetype)initWithUrl:(NSString*)url;

@end