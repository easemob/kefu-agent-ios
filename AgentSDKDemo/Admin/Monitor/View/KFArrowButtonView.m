//
//  KFArrowButtonView.m
//  AgentSDKDemo
//
//  Created by afanda on 12/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "KFArrowButtonView.h"
#import "UIColor+KFColor.h"

@implementation KFArrowButtonView
{
    UIButton *_button;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)setNormalText:(NSString *)normalText {
    CGSize size = [normalText boundingRectWithSize:CGSizeMake(MAXFLOAT, self.height) options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{
                                               NSFontAttributeName:[UIFont systemFontOfSize:15.0],
                                               }
                                     context:nil].size;
    [_button setTitle:normalText forState:UIControlStateNormal];
    _button.frame = CGRectMake(10, 0, size.width + 5, self.height);
}

- (void)setSelectedText:(NSString *)selectedText {
    CGSize size = [selectedText boundingRectWithSize:CGSizeMake(MAXFLOAT, self.height) options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{
                                                     NSFontAttributeName:[UIFont systemFontOfSize:15.0],
                                                     }
                                           context:nil].size;
    [_button setTitle:selectedText forState:UIControlStateSelected];
    _button.frame = CGRectMake(10, 0, size.width + 20, self.height);
}

- (void)layoutSubviews {
    [_button setTitleEdgeInsets:UIEdgeInsetsMake(0, -20, 0,0)];
    [_button setImageEdgeInsets:UIEdgeInsetsMake(0, _button.width-10, 0, 0)];
    
}

- (void)initUI {
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_button setTitleColor:[UIColor colorWithHexString:@"#4D4D4D"] forState:UIControlStateNormal];
    [_button setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    [_button setImage:[UIImage imageNamed:@"up"] forState:UIControlStateSelected];
    [_button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button];
}


- (void)btnClicked:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(arrowButtonClicked:)]) {
        [_delegate arrowButtonClicked:_button];
    }
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
