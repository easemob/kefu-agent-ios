//
//  HDSelectButton.m
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/3/1.
//  Copyright © 2018年 环信. All rights reserved.
//

#import "HDSelectButton.h"

@interface HDSelectButton(){
    UIView *_stampView;
}
@end

@implementation HDSelectButton

- (void)showUnReadStamp {
    if (_stampView) {
        [_stampView setHidden: NO];
        return;
    }
    _stampView = [self setupStampView];
    CGRect frame = _stampView.frame;
    frame.origin.x = self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width + 4;
    frame.origin.y = self.titleLabel.frame.origin.y - 2;
    _stampView.frame = frame;
    [self addSubview:_stampView];
    [_stampView setHidden: NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)hiddenUnReadStamp {
    [_stampView setHidden: YES];
}

- (UIView *)setupStampView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
    view.backgroundColor = [UIColor redColor];
    view.layer.cornerRadius = 4;
    view.layer.masksToBounds = YES;
    return view;
}

@end
