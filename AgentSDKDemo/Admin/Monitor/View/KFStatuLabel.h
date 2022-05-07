//
//  KFStatuLabel.h
//  AgentSDKDemo
//
//  Created by afanda on 12/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KFStatuLabel : UIView

- (instancetype)initWithFrame:(CGRect)frame status:(HDAgentLoginStatus)status;

@property (nonatomic, assign) HDAgentLoginStatus status;

@property (nonatomic, copy) NSString *text;

@property (nonatomic, assign) CGFloat fontSize;

@end
