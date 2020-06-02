//
//  KFStatuLabel.m
//  AgentSDKDemo
//
//  Created by afanda on 12/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "KFStatuLabel.h"
#import "UIColor+KFColor.h"
@implementation KFStatuLabel
{
    UIImageView *_icon;
    UILabel *_countLabel;
}

- (instancetype)initWithFrame:(CGRect)frame status:(HDAgentLoginStatus)status
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
        self.status = status;
    }
    return self;
}

- (void)setStatus:(HDAgentLoginStatus)status {
    NSString *colorName = @"";
    switch (status) {
        case HDAgentLoginStatusOnline: {
            colorName = @"#9FF806";
             break;
        }
        case HDAgentLoginStatusBusy: {
            colorName = @"#F9331C";
            break;
        }
        case HDAgentLoginStatusLeave:{
            colorName = @"#29A9EA";
            break;
        }
        case HDAgentLoginStatusHidden: {
            colorName = @"#EFBB57";
            break;
        }
        case HDAgentLoginStatusOffline: {
            colorName = @"#D8D8D8";
            break;
        }
        default:
            break;
    }
    _icon.backgroundColor = [UIColor colorWithHexString:colorName];
}

- (void)setFontSize:(CGFloat)fontSize {
    _countLabel.font = [UIFont systemFontOfSize:fontSize];
}

- (void)setText:(NSString *)text {
    _countLabel.text = text;
}

- (void)initUI {
    CGFloat wh = self.height-10;
    _icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, wh, wh)];
    _icon.layer.cornerRadius = (self.height - 10)/2;
    _icon.layer.masksToBounds = NO;
    [self addSubview:_icon];
    
    _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_icon.frame)+5, 0, self.width-self.height-5, self.height)];
    _countLabel.font = [UIFont systemFontOfSize:10];
    _countLabel.textColor = UIColor.grayColor;
    [self addSubview:_countLabel];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
