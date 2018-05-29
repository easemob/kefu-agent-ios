//
//  KFChatViewRecallCell.m
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/5/29.
//  Copyright © 2018年 环信. All rights reserved.
//

#import "KFChatViewRecallCell.h"
#define kRecallMsg @"您撤回了一条消息"

@implementation KFChatViewRecallCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    self.backgroundColor = [UIColor clearColor];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.font = [UIFont systemFontOfSize:13];
    self.textLabel.textColor = RGBACOLOR(0x9b, 0x9b, 0x9b, 1);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.text = kRecallMsg;
    self.textLabel.frame = self.contentView.bounds;
}

@end
