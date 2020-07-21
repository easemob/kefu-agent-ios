//
//  DXTableViewCellType1.m
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "DXTableViewCellType1.h"

#import "DXTipView.h"

@interface DXTableViewCellType1 ()
{
    UIView *_lineView;
    UIImageView *_stateView;
}

@end

@implementation DXTableViewCellType1

@synthesize headerImageView = _headerImageView;
@synthesize titleLabel = _titleLabel;
@synthesize contentLabel = _contentLabel;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7.5, 40, 40)];
        _headerImageView.clipsToBounds = YES;
        _headerImageView.layer.cornerRadius = CGRectGetWidth(_headerImageView.frame)/2;
        [self.contentView addSubview:_headerImageView];
        
        _stateView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headerImageView.frame) - 10, CGRectGetMaxY(_headerImageView.frame) - 7.5, 10, 10)];
        _stateView.clipsToBounds = YES;
        [self.contentView addSubview:_stateView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headerImageView.frame) + 10, 9, self.frame.size.width - CGRectGetMaxX(_headerImageView.frame) - 20 - 110, 16)];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:16.0];
        _titleLabel.textColor = RGBACOLOR(0x1a, 0x1a, 0x1a, 1);
        [self.contentView addSubview:_titleLabel];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_titleLabel.frame), CGRectGetMaxY(self.frame) - 17.0, self.frame.size.width - CGRectGetMaxX(_headerImageView.frame) - 20, 12)];
        _contentLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor = RGBACOLOR(0x99, 0x99, 0x99, 1);
        _contentLabel.font = [UIFont systemFontOfSize:12.0];
        [self.contentView addSubview:_contentLabel];
        
        _unreadLabel = [[DXTipView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headerImageView.frame) - 15, 5, 30, 20)];
        _unreadLabel.tipNumber = nil;
        [self.contentView addSubview:_unreadLabel];
        [self.contentView bringSubviewToFront:_unreadLabel];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, CGRectGetWidth(self.frame), 1)];
        _lineView.backgroundColor = RGBACOLOR(0xe5, 0xe5, 0xe5, 1);
        [self.contentView addSubview:_lineView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _lineView.frame = CGRectMake(0, self.frame.size.height-1, CGRectGetWidth(self.frame), 1);
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_headerImageView.frame) + 10, 9, self.frame.size.width - CGRectGetMaxX(_headerImageView.frame) - 20 - 110, 19);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(HDConversation *)model
{
    NSInteger count = model.unreadCount;
    if (count == 0) {
        _unreadLabel.hidden = YES;
    }
    else{
        NSString *string = @"";
        if (count > 99) {
            string = [NSString stringWithFormat:@"%i+", 99];
        }
        else{
            string = [NSString stringWithFormat:@"%ld", (long)count];
        }
        _unreadLabel.tipNumber = string;
        _unreadLabel.hidden = NO;
    }
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.chatter.avatar] placeholderImage:[UIImage imageNamed:@"default_agent_avatar"]];
    self.titleLabel.text = model.chatter.nicename;
    if ([model.chatter.onLineState isEqualToString:USER_STATE_ONLINE]) {
        _stateView.image = [UIImage imageNamed:@"state_green"];
        _contentLabel.text = @"空闲";
    } else if ([model.chatter.onLineState isEqualToString:USER_STATE_BUSY]) {
        _stateView.image = [UIImage imageNamed:@"state_red"];
        _contentLabel.text = @"忙碌";
    } else if ([model.chatter.onLineState isEqualToString:USER_STATE_LEAVE]) {
        _stateView.image = [UIImage imageNamed:@"state_blue"];
        _contentLabel.text = @"离开";
    } else if([model.chatter.onLineState isEqualToString:USER_STATE_OFFLINE]) {
        _stateView.image = [UIImage imageNamed:@"state_gray"];
        _contentLabel.text = @"离线";
    } else {
        _stateView.image = [UIImage imageNamed:@"state_yellow"];
        _contentLabel.text = @"隐身";
    }
}

@end
