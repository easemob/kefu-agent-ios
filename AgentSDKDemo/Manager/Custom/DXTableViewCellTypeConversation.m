//
//  DXTableViewCellTypeConversation.m
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "DXTableViewCellTypeConversation.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "NSDate+Formatter.h"
#import "DXTipView.h"
#import "EmotionEscape.h"
#import "HDMessage+Category.h"

#define kHeadImageViewLeft 11.f
#define kHeadImageViewTop 10.f
#define kHeadImageViewWidth 55.f

#define kLabelTop 9.f

#define kRecallMsg @"您撤回了一条消息"


@interface DXTableViewCellTypeConversation (){
    UIView *_lineView;
}

@property (nonatomic, strong) UIImageView *channelImageView;

@end

@implementation DXTableViewCellTypeConversation

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
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
        
        _tipView = [[DXTipView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headerImageView.frame) - 15, 5, 30, 20)];
        _tipView.tipNumber = nil;
        [self.contentView addSubview:_tipView];
        [self.contentView bringSubviewToFront:_tipView];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, CGRectGetWidth(self.frame), 1)];
        _lineView.backgroundColor = RGBACOLOR(0xe5, 0xe5, 0xe5, 1);
        [self.contentView addSubview:_lineView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _timeLabel.frame = CGRectMake(self.frame.size.width - 111, kLabelTop, CGRectGetWidth(_timeLabel.frame), CGRectGetHeight(_timeLabel.frame));
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_headerImageView.frame) + 10, kLabelTop, self.frame.size.width - CGRectGetMaxX(_headerImageView.frame) - 20 - 110, 19);
    _lineView.frame = CGRectMake(0, self.frame.size.height-1, CGRectGetWidth(self.frame), 1);
    _tipView.frame = CGRectMake(self.frame.size.width - 40, CGRectGetMaxY(_timeLabel.frame) + 8, 30, 20);
}

- (void)setModel:(HDConversation *)model
{
    NSInteger count = model.unreadCount;
    if (count == 0) {
        _tipView.tipNumber = nil;
    }
    else{
        NSString *string = @"";
        if (count > 99) {
            string = [NSString stringWithFormat:@"%i+", 99];
        }
        else{
            string = [NSString stringWithFormat:@"%ld", (long)count];
        }
        _tipView.tipNumber = string;
    }
    
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:model.vistor.avatar] placeholderImage:[UIImage imageNamed:@"default_customer_avatar"]];
    _titleLabel.text = model.chatter ? model.chatter.nicename:model.vistor.nicename;
    NSString *timeDes = model.lastMessage.timeDes;
    if (model.lastMessage.nBody == nil) {
        timeDes = [[NSDate dateWithTimeIntervalSince1970:model.createDateTime/1000] formattedDateDescription];
    }
    _timeLabel.text =timeDes;
    if ([model.lastMessage isRecall]) {
        _contentLabel.text = kRecallMsg;
    }else {
        switch (model.lastMessage.type) {
            case HDMessageBodyTypeText: {
                HDTextMessageBody *body = (HDTextMessageBody *)model.lastMessage.nBody;
                NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[[EmotionEscape sharedInstance] attStringFromTextForChatting:body.text textFont:_contentLabel.font]];
                _contentLabel.attributedText = attributedString;
                break;
            }
            default:
                break;
        }
        
        if (model.lastMessage.type!=HDMessageBodyTypeText) {
            _contentLabel.text = [Helper getMessageContent:model.lastMessage];
        }
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

- (void)setMsgModel:(HDMessage *)model
{
    _headerImageView.image = model.isSender?[UIImage imageNamed:@"default_agent_avatar"]:[UIImage imageNamed:@"default_customer_avatar"];
    _titleLabel.text = model.from;
    _timeLabel.text = model.timeDes;
    _contentLabel.text = [model isRecall] ? kRecallMsg : [ConvertToCommonEmoticonsHelper convertToSystemEmoticons:[Helper getMessageContent:model]];

}

- (void)setHistoryModel:(HDConversation *)model
{
    _headerImageView.image = [UIImage imageNamed:@"default_customer_avatar"];
    _titleLabel.text = model.chatter?model.chatter.nicename:model.vistor.nicename;
    NSString *startTime = @"";
    if (model.startDateTime.length > 11) {
        startTime = [model.startDateTime substringToIndex:11];
    }
    _timeLabel.text = startTime;
    _contentLabel.text = [model.lastMessage isRecall] ? kRecallMsg : [ConvertToCommonEmoticonsHelper convertToSystemEmoticons:[Helper getMessageContent:model.lastMessage]];
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

@end

@implementation DXLoadmoreCell {
    BOOL _hasMore;
    UIActivityIndicatorView *_indicator;
    UILabel *_titleLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
        | UIViewAutoresizingFlexibleRightMargin
        | UIViewAutoresizingFlexibleTopMargin
        | UIViewAutoresizingFlexibleBottomMargin;
        _indicator.color = [UIColor grayColor];
        _indicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.frame = CGRectMake(0, 0, KScreenWidth, CGRectGetHeight(self.frame));
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor colorWithWhite:0.265 alpha:1.000];
        _titleLabel.textAlignment = NSTextAlignmentCenter;

//        [self.contentView addSubview:_indicator];
        [self.contentView addSubview:_titleLabel];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //[super setSelected:selected animated:animated];
    //此处无交互
}

- (void)setHasMore:(BOOL)hasMore {
    if (hasMore) {
        _indicator.hidden = NO;
        [_indicator startAnimating];
        _titleLabel.text = @"点击加载更多";
    } else {
        _indicator.hidden = YES;
        [_indicator stopAnimating];
        _titleLabel.text = @"";
    }
}

@end
