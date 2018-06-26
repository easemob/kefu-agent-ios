//
//  KFLeaveMsgCommentCell.m
//  EMCSApp
//
//  Created by afanda on 16/11/4.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "KFLeaveMsgCommentCell.h"
#import "LeaveMsgAttatchmentView.h"
#import "MessageReadManager.h"
#import "NSDate+Formatter.h"
#define kDefaultLeft 65.f

@implementation KFLeaveMsgCommentCell
{
    UILabel *_timeLabel;
    UILabel *_unreadLabel;
    UILabel *_detailLabel;
    UIView  *_lineView;
    UIView  *_lineView2;
    UIView  *_attchmentView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self setUI];
    }
    return self;
}

- (void)setUI {
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth - 200, 7, 190, 16)];
    _timeLabel.font = [UIFont systemFontOfSize:13];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_timeLabel];
    
    _unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth - 45, CGRectGetMaxY(_timeLabel.frame) + 5.f, 20, 20)];
    _unreadLabel.backgroundColor = RGBACOLOR(242, 83, 131, 1);
    _unreadLabel.textColor = [UIColor whiteColor];
    
    _unreadLabel.textAlignment = NSTextAlignmentCenter;
    _unreadLabel.font = [UIFont systemFontOfSize:11];
    _unreadLabel.layer.cornerRadius = 10;
    _unreadLabel.clipsToBounds = YES;
    [self.contentView addSubview:_unreadLabel];
    
    _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 30, KScreenWidth-80, 20)];
    _detailLabel.backgroundColor = [UIColor clearColor];
    _detailLabel.font = [UIFont systemFontOfSize:13];
    _detailLabel.numberOfLines = 0;
    _detailLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_detailLabel];
    
    self.textLabel.backgroundColor = [UIColor clearColor];
    
    _attchmentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 0)];
    _attchmentView.userInteractionEnabled = YES;
    [self.contentView addSubview:_attchmentView];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 1)];
    _lineView.backgroundColor = RGBACOLOR(207, 210, 213, 0.7);
    [self.contentView addSubview:_lineView];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (![_unreadLabel isHidden]) {
        _unreadLabel.backgroundColor = RGBACOLOR(242, 83, 131, 1);
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if (![_unreadLabel isHidden]) {
        _unreadLabel.backgroundColor = RGBACOLOR(242, 83, 131, 1);
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGRect frame = self.imageView.frame;
    
    [self.imageView sd_setImageWithURL:_imageURL placeholderImage:_placeholderImage];
    self.imageView.frame = CGRectMake(10, 7, 45, 45);
    self.imageView.layer.cornerRadius = CGRectGetWidth(self.imageView.frame)/2;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.layer.masksToBounds = YES;
    
    self.textLabel.text = _name;
    self.textLabel.font = [UIFont boldSystemFontOfSize:16];
    self.textLabel.frame = CGRectMake(65, 10, 175, 20);
    
    _detailLabel.text = _model.content;
    _timeLabel.text =[self formatDate: _model.createDate];
    if (_unreadCount > 0) {
        if (_unreadCount < 9) {
            _unreadLabel.font = [UIFont systemFontOfSize:13];
        }else if(_unreadCount > 9 && _unreadCount < 99){
            _unreadLabel.font = [UIFont systemFontOfSize:12];
        }else{
            _unreadLabel.font = [UIFont systemFontOfSize:10];
        }
        [_unreadLabel setHidden:NO];
        [self.contentView bringSubviewToFront:_unreadLabel];
        _unreadLabel.text = [NSString stringWithFormat:@"%ld",(long)_unreadCount];
    }else{
        [_unreadLabel setHidden:YES];
    }
    
    CGFloat height = [KFLeaveMsgCommentCell _heightForContent:_detailMsg];

    _detailLabel.height = [NSString heightOfString:_model.content font:13 width:KScreenWidth-80];
    
    frame = _lineView.frame;
    frame.origin.y = 0;
    _lineView.frame = frame;
    
    frame = _lineView2.frame;
    frame.origin.y = 60 + height;
    _lineView2.frame = frame;
    
    frame = _attchmentView.frame;
    frame.origin.y = CGRectGetMaxY(_detailLabel.frame);
    _attchmentView.frame = frame;
}

- (void)setModel:(HLeaveMessageComment *)model
{
    self.name = model.creator.username;
    self.placeholderImage = [UIImage imageNamed:@"default_customer_avatar"];
    self.detailMsg = model.content;
    [self _setAttachments:model.attachments];
    if (model.attachments) {
        [self.contentView addSubview:_lineView2];
    } else {
        [_lineView2 removeFromSuperview];
    }
    
    _model = model;
}

+(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

+(CGFloat)tableView:(UITableView *)tableView model:(HLeaveMessageComment *)model
{
    return 60.f + [KFLeaveMsgCommentCell _heightForModel:model];
}

- (void)_setAttachments:(NSArray *)attachments
{
    _attachments = attachments;
    for (UIView *subView in [_attchmentView subviews]) {
        [subView removeFromSuperview];
    }
    
    if (attachments == nil || [attachments count] == 0) {
        return;
    }
    
    [self.contentView addSubview:_lineView2];
    
    CGFloat left = kDefaultLeft;
    CGFloat height = 40;
    NSInteger index = 0;
    for (HLeaveMessageCommentAttachment *attachment in attachments) {
        if (left + [LeaveMsgAttatchmentView widthForName:attachment.attachmentName maxWidth:KScreenWidth - kDefaultLeft - 10] >= KScreenWidth) {
            left = kDefaultLeft;
            height += 40;
        }
        LeaveMsgAttatchmentView *attatchmentView = [[LeaveMsgAttatchmentView alloc] initWithFrame:CGRectMake(left, height - 30, [LeaveMsgAttatchmentView widthForName:attachment.attachmentName maxWidth:KScreenWidth - kDefaultLeft - 10], 30)
                                                                                             edit:NO
                                                                                            kfmodel:attachment];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAttatchmentAction:)];
        [attatchmentView addGestureRecognizer:tap];
        attatchmentView.tag = index;
        [_attchmentView addSubview:attatchmentView];
        index ++;
        left += [LeaveMsgAttatchmentView widthForName:attachment.attachmentName maxWidth:KScreenWidth - kDefaultLeft - 10] + 10;
    }
    
    CGRect frame = _attchmentView.frame;
    frame.size.height = height + 10.f;
    _attchmentView.frame = frame;
}

- (void)tapAttatchmentAction:(id)sender
{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    NSInteger index = tap.view.tag;
    if ([_attachments count] > index) {
        HLeaveMessageCommentAttachment *attachment = [_attachments objectAtIndex:index];
        if ([self isImageSuffix:attachment.type]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didselectImageAttachment:)]) {
                [self.delegate didselectImageAttachment:attachment];
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectFileAttachment:)]) {
                [self.delegate didSelectFileAttachment:attachment];
            }
        }
    }
}

- (BOOL)isImageSuffix:(NSString *)aFileName {
    NSString *fileName = [aFileName lowercaseString];
    BOOL ret = NO;
    do {
        if ([fileName containsString:@"png"]) {
            ret = YES;
            break;
        }
        if ([fileName containsString:@"jpg"]) {
            ret = YES;
            break;
        }
        if ([fileName containsString:@"image"]) {
            ret = YES;
            break;
        }
        if ([fileName containsString:@"img"]) {
            ret = YES;
            break;
        }
        if ([fileName containsString:@"jpeg"]) {
            ret = YES;
            break;
        }
    } while (0);
    
    return ret;
}

+ (CGFloat)_heightForContent:(NSString*)content
{
    if (content.length == 0) {
        return 60.f;
    }
    
    CGFloat height = 0;
    CGRect rect = [content boundingRectWithSize:CGSizeMake(KScreenWidth-80, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}
                                        context:nil];
    if (rect.size.height > 60) {
        height = rect.size.height ;
    } else {
        height = 60.f;
    }
    return height;
}

+ (CGFloat)_heightForAttachments:(NSArray*)attachments
{
    if ([attachments count] > 0) {
        CGFloat left = kDefaultLeft;
        CGFloat height = 40;
        for (HLeaveMessageCommentAttachment *attachment in attachments) {
            if (left + [LeaveMsgAttatchmentView widthForName:attachment.attachmentName maxWidth:KScreenWidth - kDefaultLeft - 10] >= KScreenWidth) {
                left = kDefaultLeft;
                height += 40;
            }
            left += [LeaveMsgAttatchmentView widthForName:attachment.attachmentName maxWidth:KScreenWidth - kDefaultLeft - 10] + 10;
        }
        return height + 10.f;
    } else {
        return 0.f;
    }
}

+ (CGFloat)_heightForModel:(HLeaveMessageComment *)model
{
    CGFloat height = 0;
    height += [self _heightForContent:model.content];
    height += [self _heightForAttachments:model.attachments];
    return height;
}

- (NSString*)formatDate:(NSString*)time
{
    if (time.length > 0) {
        NSDateFormatter *format =[[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000Z"];
        NSDate *date = [format dateFromString:time];
        return [date minuteDescription];
    }
    return @"";
}

@end




