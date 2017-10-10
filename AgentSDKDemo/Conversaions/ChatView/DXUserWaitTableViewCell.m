//
//  DXUserWaitTableViewCell.m
//  EMCSApp
//
//  Created by EaseMob on 15/4/18.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "DXUserWaitTableViewCell.h"

#import "ConvertToCommonEmoticonsHelper.h"
#import "NSDate+Formatter.h"

#define kHeadImageViewLeft 10.f
#define kHeadImageViewTop 7.5f
#define kHeadImageViewWidth 40.f

#define kLabelTop 9.f

#define kJoinButtonTop 39.f
#define kJoinButtonWidth 32.f
#define kJoinButtonHeight 32.f

#define kLineViewHeight 1.f

@implementation DXUserWaitTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kHeadImageViewLeft, kHeadImageViewTop, kHeadImageViewWidth, kHeadImageViewWidth)];
        _headerImageView.clipsToBounds = YES;
        _headerImageView.layer.cornerRadius = kHeadImageViewWidth/2;
        [self.contentView addSubview:_headerImageView];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headerImageView.frame) + 10, kLabelTop, 100, 12)];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = RGBACOLOR(0x99, 0x99, 0x99, 1);
        _timeLabel.font = [UIFont systemFontOfSize:12.0];
        [self.contentView addSubview:_timeLabel];
        
//        _joinupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _joinupBtn.frame = CGRectMake(KScreenWidth - kJoinButtonWidth - 4.f, CGRectGetMaxY(_timeLabel.frame) + 5.f, kJoinButtonWidth, kJoinButtonHeight);
//        [_joinupBtn setImage:[UIImage imageNamed:@"icon_contact"] forState:UIControlStateNormal];
//        [_joinupBtn addTarget:self action:@selector(joinConversation) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:_joinupBtn];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headerImageView.frame) + 10, kLabelTop, self.frame.size.width - CGRectGetMaxX(_headerImageView.frame) - 20 - 110, 16)];
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
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-kLineViewHeight, CGRectGetWidth(self.frame), kLineViewHeight)];
        _lineView.backgroundColor = RGBACOLOR(0xe5, 0xe5, 0xe5, 1);
        [self.contentView addSubview:_lineView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_headerImageView.frame) + 10, kLabelTop, self.frame.size.width - CGRectGetMaxX(_headerImageView.frame) - 20 - 110, 19);
    _timeLabel.frame = CGRectMake(self.frame.size.width - 111, kLabelTop, CGRectGetWidth(_timeLabel.frame), CGRectGetHeight(_timeLabel.frame));
    _lineView.frame = CGRectMake(0, self.frame.size.height-kLineViewHeight, CGRectGetWidth(self.frame), kLineViewHeight);
    _joinupBtn.frame = CGRectMake(KScreenWidth - kJoinButtonWidth - 4.f, (self.height - kJoinButtonHeight)/2, kJoinButtonWidth, kJoinButtonHeight);
}

- (void)setModel:(HDWaitUser *)model
{
    _model = model;
    _headerImageView.image = [UIImage imageNamed:@"default_customer_avatar"];
    _titleLabel.text = model.userName;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    _timeLabel.text = [[formatter dateFromString:model.createDateTime] formattedDateDescription];
    _contentLabel.text = [ConvertToCommonEmoticonsHelper convertToSystemEmoticons:[Helper getMessageContent:model]];
}

@end
