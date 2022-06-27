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

#import "EMChatViewCell.h"
#import "UIResponder+Router.h"

NSString *const kResendButtonTapEventName = @"kResendButtonTapEventName";
NSString *const kSmartButtonTapEventName = @"kSmartButtonTapEventName";
NSString *const kShouldResendCell = @"kShouldResendCell";

@implementation EMChatViewCell

- (id)initWithMessageModel:(HDMessage *)model reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithMessageModel:model reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.headImageView.clipsToBounds = YES;
        self.headImageView.layer.cornerRadius = 3.0;
    }
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bubbleFrame = _bubbleView.frame;
    bubbleFrame.origin.y = self.headImageView.frame.origin.y + 5.0f;
    
    if (self.messageModel.isSender) {
        // 菊花状态 （因不确定菊花具体位置，要在子类中实现位置的修改）
        _hasRead.hidden = YES;
        switch (self.messageModel.status) {
            case HDMessageDeliveryState_Delivering:
            {
                [_activityView setHidden:NO];
                [_retryButton setHidden:YES];
                [_activtiy setHidden:NO];
                [_activtiy startAnimating];
            }
                break;
            case HDMessageDeliveryState_Delivered:
            {
                [_activtiy stopAnimating];
                [_retryButton setHidden:YES];
                /*
                if (self.messageModel.message.isReadAcked)
                {
                    _activityView.hidden = NO;
                    _hasRead.hidden = NO;
                }
                else
                {
                    [_activityView setHidden:YES];
                }*/
                _activityView.hidden = NO;
            }
                break;
            case HDMessageDeliveryState_Pending:
            {
                break;
            }
            case HDMessageDeliveryState_Failure:
            {
                [_activityView setHidden:NO];
                [_activtiy stopAnimating];
                [_activtiy setHidden:YES];
                [_retryButton setHidden:NO];
            }
                break;
            default:
                break;
        }
        
        bubbleFrame.origin.x = self.headImageView.frame.origin.x - bubbleFrame.size.width - HEAD_PADDING;
        _bubbleView.frame = bubbleFrame;

        CGRect frame = self.activityView.frame;
        if (_hasRead.hidden)
        {
            frame.size.width = SEND_STATUS_SIZE;
        }
        else
        {
            frame.size.width = _hasRead.frame.size.width;
        }
        frame.origin.x = bubbleFrame.origin.x - frame.size.width - ACTIVTIYVIEW_BUBBLE_PADDING;
        frame.origin.y = _bubbleView.center.y - frame.size.height / 2;
        self.activityView.frame = frame;
    }
    else{
        bubbleFrame.origin.x = HEAD_PADDING * 2 + HEAD_SIZE;
        _bubbleView.frame = bubbleFrame;
        if (self.messageModel.type == HDMessageBodyTypeText) {
            // 智能辅助按钮
            if ( [HDClient sharedClient].currentAgentUser.smartEnable) {
            [self.contentView addSubview:self.smartBtn];
            [self.smartBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(_bubbleView.mas_trailing).offset(5);
                make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(0);
                make.width.height.offset(32);
            }];
            }
        }
      
    }
}

- (void)setMessageModel:(HDMessage *)model
{
    [super setMessageModel:model];

    _bubbleView.model = self.messageModel;
    [_bubbleView sizeToFit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - action

// 重发按钮事件
-(void)retryButtonPressed:(UIButton *)sender
{
    [self routerEventWithName:kResendButtonTapEventName
                     userInfo:@{kShouldResendCell:self}];
}
// 辅助按钮事件
-(void)smartBtnAction:(UIButton *)sender
{
    
    sender.selected = !sender.selected;
    [self routerEventWithName:kSmartButtonTapEventName
                     userInfo:@{KMESSAGEKEY:self.messageModel,@"smartButton":sender}];
}
#pragma mark - private

- (void)setupSubviewsForMessageModel:(HDMessage *)messageModel
{
    [super setupSubviewsForMessageModel:messageModel];
    
    if (messageModel.isSender) {
        // 发送进度显示view
        _activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SEND_STATUS_SIZE, SEND_STATUS_SIZE)];
        [_activityView setHidden:YES];
        [self.contentView addSubview:_activityView];
        
        // 重发按钮
        _retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _retryButton.frame = CGRectMake(0, 0, SEND_STATUS_SIZE, SEND_STATUS_SIZE);
        [_retryButton addTarget:self action:@selector(retryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//        [_retryButton setImage:[UIImage imageNamed:@"messageSendFail.png"] forState:UIControlStateNormal];
        [_retryButton setBackgroundImage:[UIImage imageNamed:@"tips_false_message"] forState:UIControlStateNormal];
        //[_retryButton setBackgroundColor:[UIColor redColor]];
        [_activityView addSubview:_retryButton];
        
        // 菊花
        _activtiy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activtiy.backgroundColor = [UIColor clearColor];
        [_activityView addSubview:_activtiy];

        //已读
        _hasRead = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SEND_STATUS_SIZE, SEND_STATUS_SIZE)];
        _hasRead.text = @"已读";
        _hasRead.textAlignment = NSTextAlignmentCenter;
        _hasRead.font = [UIFont systemFontOfSize:12];
        [_hasRead sizeToFit];
        [_activityView addSubview:_hasRead];
    }
    
    _bubbleView = [self bubbleViewForMessageModel:messageModel];
    [self.contentView addSubview:_bubbleView];
}
- (UIButton *)smartBtn{
    if (!_smartBtn) {
        _smartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _smartBtn.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:1];
//        [_smartBtn setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
//        [_smartBtn setTitle:@"上条" forState:(UIControlStateNormal)];
        [_smartBtn setImage:[UIImage imageNamed:@"smart@2x.png"] forState:UIControlStateNormal];
        [_smartBtn setImage:[UIImage imageNamed:@"smartselect@2x.png"] forState:UIControlStateSelected];
        [self addSubview:_smartBtn];
        [_smartBtn addTarget:self action:@selector(smartBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _smartBtn;
}
- (EMChatBaseBubbleView *)bubbleViewForMessageModel:(HDMessage *)messageModel
{
    switch (messageModel.type) {
        case HDMessageBodyTypeText:
        {
            HDExtMsgType type = HDExtMsgTypeGeneral;
            type = [HDUtils getMessageExtType:messageModel];
            if (type == HDExtMsgTypeForm) {
                return [[HDChatFormBubbleView alloc] init];
            }else if (type == HDExtMsgTypeArticle) {
                return [[KFChatArticleBubbleView alloc] init];
            }else if (type == HDExtMsgTypevideoPlayback) {
                return [[HDChatVideoDetailBubbleView  alloc] init];
            }else if(type == HDExtMsgTypeHtml){
                
                return [[KFWebBubbleView  alloc] init];
            }
            return [[EMChatTextBubbleView alloc] init];
        }
            break;
        case HDMessageBodyTypeImage:
        {
            return [[EMChatImageBubbleView alloc] init];
        }
            break;
        case HDMessageBodyTypeLocation:
        {
            return [[EMChatLocationBubbleView alloc] init];
        }
            break;
        case HDMessageBodyTypeImageText:
        {
            return [[EMChatImageTextBubbleView alloc] init];
        }
            break;
        case HDMessageBodyTypeVoice:
        {
            EMChatAudioBubbleView *audio =  [[EMChatAudioBubbleView alloc] init];
            return audio;
        }
            break;
        case HDMessageBodyTypeFile:
        {
            return [[EMChatFileBubbleView alloc] init];
        }
            break;
        case HDMessageBodyTypeVideo:
        {
            return [[HDChatVideoBubbleView alloc] init];
        }
            break;
        case HDMessageBodyTypePlayBack:
        {
            return [[HDChatVideoDetailBubbleView alloc] init];
        }
            break;
             
        default:
            break;
    }
    
    return nil;
}

+ (CGFloat)bubbleViewHeightForMessageModel:(HDMessage *)messageModel
{
    switch (messageModel.type) {
        case HDMessageBodyTypeText:
        {
            HDExtMsgType type = HDExtMsgTypeGeneral;
            type = [HDUtils getMessageExtType:messageModel];
            if (type == HDExtMsgTypeForm) {
                return [HDChatFormBubbleView heightForBubbleWithObject:messageModel];
            }else if(type == HDExtMsgTypeArticle){
           
                return [KFChatArticleBubbleView heightForBubbleWithObject:messageModel];
            }
            else if(type == HDExtMsgTypevideoPlayback){
           
                return [HDChatVideoDetailBubbleView heightForBubbleWithObject:messageModel];
            }
            else if(type == HDExtMsgTypeHtml){
           
                return [KFWebBubbleView heightForBubbleWithObject:messageModel];
            }
            return [EMChatTextBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case HDMessageBodyTypeImage:
        {
            return [EMChatImageBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case HDMessageBodyTypeLocation:
        {
            return [EMChatLocationBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case HDMessageBodyTypeImageText:
        {
            return [EMChatImageTextBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case HDMessageBodyTypeVoice:
        {
            return [EMChatAudioBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case HDMessageBodyTypeFile:
        {
            return [EMChatFileBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case HDMessageBodyTypeVideo:
        {
            return [HDChatVideoBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
            /*
        case eMessageBodyType_Voice:
        {
            return [EMChatAudioBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case eMessageBodyType_Video:
        {
            return [EMChatVideoBubbleView heightForBubbleWithObject:messageModel];
        }
            break;*/
        default:
            break;
    }
    
    return HEAD_SIZE;
}

#pragma mark - public

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(HDMessage *)model
{
    NSInteger bubbleHeight = [self bubbleViewHeightForMessageModel:model];
    NSInteger headHeight = HEAD_PADDING * 2 + HEAD_SIZE;
//    if (/*model.isChatGroup &&*/ !model.isSender) {
//        headHeight += NAME_LABEL_HEIGHT;
//    }
//    return headHeight - 20 > bubbleHeight ? headHeight + CELLPADDING:bubbleHeight + CELLPADDING + 5.f;
    return MAX(headHeight, bubbleHeight) + CELLPADDING * 2;
}


@end
