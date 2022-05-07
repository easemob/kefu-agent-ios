/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "EMChatViewBaseCell.h"
#import "UIImageView+EMWebCache.h"
#import "HDMessage+Category.h"

NSString *const kRouterEventChatHeadImageTapEventName = @"kRouterEventChatHeadImageTapEventName";

@interface EMChatViewBaseCell()

@end

@implementation EMChatViewBaseCell

- (id)initWithMessageModel:(HDMessage *)model reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImagePressed:)];
        CGFloat originX = HEAD_X;
        if (model.isSender) {
            originX = self.bounds.size.width - HEAD_SIZE - HEAD_X;
        }
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(originX, CELLPADDING, HEAD_SIZE, HEAD_SIZE)];
        [_headImageView addGestureRecognizer:tap];
        _headImageView.userInteractionEnabled = YES;
        _headImageView.multipleTouchEnabled = YES;
        _headImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_headImageView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor grayColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_nameLabel];
        
        [self setupSubviewsForMessageModel:model];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = _headImageView.frame;
    frame.origin.x = _messageModel.isSender ? (self.bounds.size.width - _headImageView.frame.size.width - HEAD_PADDING) : HEAD_PADDING;
    _headImageView.frame = frame;
    
    _nameLabel.frame = CGRectMake(CGRectGetMinX(_headImageView.frame), CGRectGetMaxY(_headImageView.frame), CGRectGetWidth(_headImageView.frame), NAME_LABEL_HEIGHT);
    _headImageView.layer.cornerRadius = CGRectGetWidth(self.headImageView.frame)/2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setter

- (void)setMessageModel:(HDMessage *)messageModel
{
    _messageModel = messageModel;
    _nameLabel.hidden = NO;
    if (!messageModel.isSender) {
        self.headImageView.image = [UIImage imageNamed:@"default_agent_avatar"];
    } else {
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[HDClient sharedClient].currentAgentUser.avatar] placeholderImage:[UIImage imageNamed:@"default_agent_avatar"]];
    }
}

#pragma mark - private

-(void)headImagePressed:(id)sender
{
    [super routerEventWithName:kRouterEventChatHeadImageTapEventName userInfo:@{KMESSAGEKEY:self.messageModel}];
}

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    [super routerEventWithName:eventName userInfo:userInfo];
}

#pragma mark - public

- (void)setupSubviewsForMessageModel:(HDMessage *)model
{
    if (model.isSender) {
        self.headImageView.frame = CGRectMake(self.bounds.size.width - HEAD_SIZE - HEAD_PADDING, CELLPADDING, HEAD_SIZE, HEAD_SIZE);
    }
    else{
        self.headImageView.frame = CGRectMake(0, CELLPADDING, HEAD_SIZE, HEAD_SIZE);
    }
}

+ (NSString *)cellIdentifierForMessageModel:(HDMessage *)model
{
    NSString *identifier = @"MessageCell";
    if (model.isSender) {
        identifier = [identifier stringByAppendingString:@"Sender"];
    }
    else{
        identifier = [identifier stringByAppendingString:@"Receiver"];
    }
    
    if ([model isRecall]) {
        identifier = [identifier stringByAppendingString:@"Recell"];
    }else {
        switch (model.type) {
            case HDMessageBodyTypeText:
            {
                identifier = [identifier stringByAppendingString:@"Text"];
                HDExtMsgType type = HDExtMsgTypeGeneral;
                type = [HDUtils getMessageExtType:model];
                if (type == HDExtMsgTypeForm) {
                    identifier = [identifier stringByAppendingString:@"form"];
                }
            }
                break;
            case HDMessageBodyTypeImage:
            {
                identifier = [identifier stringByAppendingString:@"Image"];
            }
                break;
            case HDMessageBodyTypeVoice:
            {
                identifier = [identifier stringByAppendingString:@"Audio"];
            }
                break;
            case HDMessageBodyTypeLocation:
            {
                identifier = [identifier stringByAppendingString:@"Location"];
            }
                break;
            case HDMessageBodyTypeImageText:
            {
                identifier = [identifier stringByAppendingString:@"imageText"];
            }
                break;
            case HDMessageBodyTypeFile:
            {
                identifier = [identifier stringByAppendingString:@"file"];
            }
                break;
            case HDMessageBodyTypeVideo:
            {
                identifier = [identifier stringByAppendingString:@"video"];
            }
                break;
            default:
                break;
        }
    }
    return identifier;
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(HDMessage *)model
{
    return HEAD_SIZE + CELLPADDING;
}

@end
