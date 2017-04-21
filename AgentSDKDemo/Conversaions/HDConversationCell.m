//
//  HDConversationCell.m
//  AgentSDKDemo
//
//  Created by afanda on 4/14/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "HDConversationCell.h"
#import <AgentSDK/NSDate+Formatter.h>
#define kHeadImageViewLeft 11.f
#define kHeadImageViewTop 10.f
#define kHeadImageViewWidth 55.f

#define kLabelTop 9.f
@interface HDConversationCell ()
{
    UIView *_lineView;
}
@property (nonatomic, strong) UIImageView *channelImageView;
@end

@implementation HDConversationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


#pragma mark - base
- (void)initUI {
    _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
    _headerImageView.layer.masksToBounds = YES;
    _headerImageView.layer.cornerRadius = 20;
    [self.contentView addSubview:_headerImageView];
    
    _channelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_headerImageView.center.x + 5, _headerImageView.center.y + 5, 15, 15)];
    _channelImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:_channelImageView];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 111, kLabelTop, 100, 12)];
    _timeLabel.textAlignment = NSTextAlignmentRight;
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textColor = RGBACOLOR(0x99, 0x99, 0x99, 1);
    _timeLabel.font = [UIFont systemFontOfSize:12.0];
    [self.contentView addSubview:_timeLabel];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headerImageView.frame) + 10, kLabelTop, self.frame.size.width - CGRectGetMaxX(_headerImageView.frame) - 20 - 110, 16)];
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont systemFontOfSize:16.0];
    _titleLabel.textColor = RGBACOLOR(0x1a, 0x1a, 0x1a, 1);
    [self.contentView addSubview:_titleLabel];
    
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_titleLabel.frame), CGRectGetMaxY(self.frame) - 17.0, self.frame.size.width - CGRectGetMaxX(_headerImageView.frame) - 40, 12)];
    _contentLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _contentLabel.backgroundColor = [UIColor clearColor];
    _contentLabel.textColor = RGBACOLOR(0x99, 0x99, 0x99, 1);
    _contentLabel.font = [UIFont systemFontOfSize:12.0];
    [self.contentView addSubview:_contentLabel];
    
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, CGRectGetWidth(self.frame), 1)];
    _lineView.backgroundColor = RGBACOLOR(0xe5, 0xe5, 0xe5, 1);
    [self.contentView addSubview:_lineView];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _timeLabel.frame = CGRectMake(self.frame.size.width - 111, kLabelTop, CGRectGetWidth(_timeLabel.frame), CGRectGetHeight(_timeLabel.frame));
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_headerImageView.frame) + 10, kLabelTop, self.frame.size.width - CGRectGetMaxX(_headerImageView.frame) - 20 - 110, 19);
    _lineView.frame = CGRectMake(0, self.frame.size.height-1, CGRectGetWidth(self.frame), 1);
}

- (void)setModel:(ConversationModel *)model {
    NSInteger count = model.unreadCount;
    
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:model.vistor.avatar] placeholderImage:[UIImage imageNamed:@"default_customer_avatar"]];
    
    _titleLabel.text = model.chatter?model.chatter.nicename:model.vistor.nicename;
    NSString *timeDes = model.lastMessage.timeDes;
    if (model.lastMessage.body == nil) {
        timeDes = [[NSDate dateWithTimeIntervalSince1970:model.createDateTime/1000] formattedDateDescription];
    }
    _timeLabel.text =timeDes;
    NSString *content = model.lastMessage.body.content?model.lastMessage.body.content:@"";
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[[EmotionEscape sharedInstance] attStringFromTextForChatting:content textFont:_contentLabel.font]];
    _contentLabel.attributedText = attributedString;
    if ([attributedString.string isEqual:@"[表情]"] && ![model.lastMessage.body.content isEqualToString:@"[表情]"]) {
        _contentLabel.text = model.lastMessage.body.content;
    }
    if ([model.originType isEqualToString:@"app"]) {
        _channelImageView.image = [UIImage imageNamed:@"channel_APP_icon"];
    } else if ([model.originType isEqualToString:@"webim"]) {
        _channelImageView.image = [UIImage imageNamed:@"channel_web_icon"];
    } else if ([model.originType isEqualToString:@"weixin"]) {
        _channelImageView.image = [UIImage imageNamed:@"channel_wechat_icon"];
    } else if ([model.originType isEqualToString:@"weibo"]) {
        _channelImageView.image = [UIImage imageNamed:@"channel_weibo_icon"];
    } else {
        _channelImageView.image = [UIImage imageNamed:@"channel_APP_icon"];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
