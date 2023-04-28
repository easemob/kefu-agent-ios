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
    _contentLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _contentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _contentLabel.backgroundColor = [UIColor whiteColor];
    _contentLabel.numberOfLines = 0 ;
    _contentLabel.tintColor = [UIColor lightGrayColor];
    _contentLabel.font = [UIFont systemFontOfSize:self.fontSize];
    [self addSubview:_contentLabel];
}


- (void)setContent:(NSString *)content {
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[[EmotionEscape sharedInstance] attStringFromTextForChatting:content textFont:_contentLabel.font]];
    _contentLabel.attributedText = attributedString;
}

- (CGFloat)fontSize {
    return 12.f;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
