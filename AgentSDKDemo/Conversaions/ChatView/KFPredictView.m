//
//  KFPredictView.m
//  AgentSDKDemo
//
//  Created by afanda on 12/12/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "KFPredictView.h"

@implementation KFPredictView
{
    UILabel *_contentLabel;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    _contentLabel = [[UILabel alloc] initWithFrame:self.frame];
    _contentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _contentLabel.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:_contentLabel];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
