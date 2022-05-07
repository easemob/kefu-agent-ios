//
//  HLeaveMessageCell.m
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/6/12.
//  Copyright © 2018年 环信. All rights reserved.
//

#import "HLeaveMessageCell.h"

@implementation HLeaveMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lLeaveMsgCount.layer.masksToBounds = YES;
    self.lLeaveMsgCount.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
}

- (void)setupUnreadCountTextColor:(UIColor *)aColor {
    self.lLeaveMsgCount.textColor = aColor;
}

- (void)setupUnreadCountBgColor:(UIColor *)aColor; {
    self.lLeaveMsgCount.backgroundColor = aColor;
}

@end
