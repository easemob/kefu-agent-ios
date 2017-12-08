//
//  HDTipLabel.m
//  AgentSDKDemo
//
//  Created by afanda on 12/5/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "HDTipLabel.h"

#define margin 10
@implementation HDTipLabel
{
    UIImageView *_imageView; //图标
    UILabel *_textLabel; //文字
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)setImageName:(NSString *)imageName {
    _imageView.image = [UIImage imageNamed:imageName];
}

- (void)setText:(NSString *)text {
    _textLabel.text = text;
}

- (void)setFontSize:(CGFloat)fontSize {
    _textLabel.font = [UIFont systemFontOfSize:fontSize];
}

- (void)layoutSubviews {
    CGFloat labelX = CGRectGetMaxX(_imageView.frame) + margin;
    _textLabel.frame =CGRectMake(labelX, 0, self.width - labelX , self.height);
}

- (void)initUI {
    CGFloat h = self.height;
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, h-6, h-6)];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_imageView];
    _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:_textLabel];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
