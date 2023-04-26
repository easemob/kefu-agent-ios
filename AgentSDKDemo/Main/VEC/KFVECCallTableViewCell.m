//
//  KFVECCallTableViewCell.m
//  AgentSDKDemo
//
//  Created by easemob on 2023/4/25.
//  Copyright © 2023 环信. All rights reserved.
//

#import "KFVECCallTableViewCell.h"
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

@interface KFVECCallTableViewCell (){
    UIView *_lineView;
}

@property (nonatomic, strong) UIImageView *channelImageView;

@end

@implementation KFVECCallTableViewCell

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
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 100, kLabelTop, 150, 12)];
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
        _contentLabel.font = [UIFont systemFontOfSize:14.0];
        [self.contentView addSubview:_contentLabel];
        
        
        _reasonLabel = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth -80, CGRectGetMaxY(self.frame) - 17.0, 80, 12)];
        _reasonLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _reasonLabel.backgroundColor = [UIColor clearColor];
        _reasonLabel.textColor = RGBACOLOR(0x99, 0x99, 0x99, 1);
        _reasonLabel.font = [UIFont systemFontOfSize:14.0];
        [self.contentView addSubview:_reasonLabel];
        
        
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
    
    _timeLabel.frame = CGRectMake(self.frame.size.width - 155, kLabelTop, CGRectGetWidth(_timeLabel.frame), CGRectGetHeight(_timeLabel.frame));
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_headerImageView.frame) + 10, kLabelTop, self.frame.size.width - CGRectGetMaxX(_headerImageView.frame) - 20 - 110-20, 19);
    _lineView.frame = CGRectMake(0, self.frame.size.height-1, CGRectGetWidth(self.frame), 1);
    _tipView.frame = CGRectMake(self.frame.size.width - 40, CGRectGetMaxY(_timeLabel.frame) + 8, 30, 20);
}


- (void)setVECHistoryModel:(KFVecCallHistoryModel*)model
{

    _headerImageView.image = [UIImage imageNamed:@"default_customer_avatar"];
    NSString *nicename;
    NSString *username;
    
    if (model.visitorUser&& [model.visitorUser isKindOfClass:[NSDictionary class]]) {
   
        nicename =  [model.visitorUser objectForKey:@"nicename"];
        username =  [model.visitorUser objectForKey:@"username"];
    }
    _titleLabel.text = nicename ? nicename : username;
    _timeLabel.text = model.createDatetime;
    _contentLabel.text = model.techChannelName;
    
//    NORMAL  正常结束（接通后结束）
//    RING_GIVE_UP   振铃放弃（指定振铃时间内，访客挂断/离开）
//    AGENT_REJECT  客服拒接（振铃过程中客服主动挂断）
//    VISITOR_REJECT   访客拒接（振铃过程中访客主动挂断）
    
    
    if ([model.hangUpReason isEqualToString:@"NORMAL"]) {
        
        _reasonLabel.text = @"正常结束";
        _reasonLabel.textColor = [[HDAppSkin mainSkin] contentColorBlueHX];
        
    }else if([model.hangUpReason isEqualToString:@"RING_GIVE_UP"]){
        
        _reasonLabel.text = @"振铃放弃";
        _reasonLabel.textColor = [[HDAppSkin mainSkin] contentColorRed];
        
    }else if([model.hangUpReason isEqualToString:@"AGENT_REJECT"]){
        
        _reasonLabel.text = @"客服拒接";
        _reasonLabel.textColor = [[HDAppSkin mainSkin] contentColorRed];
        
    }else if([model.hangUpReason isEqualToString:@"VISITOR_REJECT"]){
        
        _reasonLabel.text = @"访客拒接";
        _reasonLabel.textColor = [[HDAppSkin mainSkin] contentColorRed];
        
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


@end
@implementation KFVECDXLoadmoreCell {
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
