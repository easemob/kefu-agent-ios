//
//  HDChatVideoDetailBubbleView.m
//  AgentSDKDemo
//
//  Created by houli on 2022/2/24.
//  Copyright © 2022 环信. All rights reserved.
//
#define kLabelFont 16.f

#define MAX_WIDTH 240

NSString *const kRouterEventVideoDetailBubbleTapEventName = @"kRouterEventVideoDetailBubbleTapEventName";

#import "HDChatVideoDetailBubbleView.h"
@interface HDChatVideoDetailBubbleView ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *sizeLabel;
@property (nonatomic, strong) UIImageView *imageView;
@end
@implementation HDChatVideoDetailBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = RGBACOLOR(0x1a, 0x1a, 0x1a, 1);
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont systemFontOfSize:kLabelFont];
        _nameLabel.numberOfLines = 2;
        [self addSubview:_nameLabel];
        _sizeLabel = [[UILabel alloc] init];
        _sizeLabel.textColor = RGBACOLOR(0x1a, 0x1a, 0x1a, 1);
        _sizeLabel.textAlignment = NSTextAlignmentLeft;
        _sizeLabel.font = [UIFont systemFontOfSize:kLabelFont];
        _sizeLabel.numberOfLines = 2;
        //        _sizeLabel.text = @"0 kb";
        _sizeLabel.text = @"";
        [self addSubview:_sizeLabel];
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.image = [UIImage imageNamed:@"ic_video_library"];
        [self addSubview:_imageView];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame.size.width -= BUBBLE_ARROW_WIDTH;
    frame = CGRectInset(frame, BUBBLE_VIEW_PADDING, BUBBLE_VIEW_PADDING);
    if (self.model.isSender) {
        frame.origin.x = BUBBLE_VIEW_PADDING;
    }else{
        frame.origin.x = BUBBLE_VIEW_PADDING + BUBBLE_ARROW_WIDTH;
    }
    frame.origin.y = BUBBLE_VIEW_PADDING;
    _imageView.frame = CGRectMake(frame.size.width - frame.size.height + 5, 5,self.height - 10.f, self.height - 10.f);
    frame.size.height = 30;
    frame.size.width -=self.height;
    self.nameLabel.frame = frame;
    self.sizeLabel.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.nameLabel.frame), CGRectGetWidth(self.nameLabel.frame), 30);
    
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize retSize = CGSizeMake(MAX_WIDTH, 75.f);
    if (self.model.ext) {
        //        retSize.height = 95;
        //        if (self.model.ext.msgtype.orderTitle && self.model.ext.msgtype.orderTitle.length > 0) {
        //            NSString *string = [NSString stringWithFormat:@"%@ %@",self.model.ext.msgtype.title,self.model.ext.msgtype.desc];
        //            NSDictionary *attributes = @{NSFontAttributeName :[UIFont systemFontOfSize:kLabelFont]};
        //            CGRect rect = [string boundingRectWithSize:CGSizeMake(kNameLabelWidth, MAXFLOAT)
        //                                               options:NSStringDrawingUsesLineFragmentOrigin
        //                                            attributes:attributes
        //                                               context:nil];
        //            CGFloat height = CGRectGetHeight(rect);
        //            if (height > 30) {
        //                retSize.height += kLabelHeight + kViewSpace;
        //            }
        //        }
    }
    
    return CGSizeMake(retSize.width + BUBBLE_VIEW_PADDING * 2 + BUBBLE_ARROW_WIDTH, retSize.height);
}

#pragma mark - setter

- (void)setModel:(HDMessage *)model
{
    [super setModel:model];
    
    NSString * str =  [KFManager sharedInstance].curChatViewConvtroller.conversationModel.chatNicename;
    
    self.sizeLabel.text = [NSString stringWithFormat:@"访客(%@)与(%@)的视频通话记录",str,[HDClient sharedClient].currentAgentUser.nicename];
    self.nameLabel.text = [NSString stringWithFormat:@"访客(%@)与(%@)的视频通话记录",str,[HDClient sharedClient].currentAgentUser.nicename];
}

#pragma mark - public

-(void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventVideoDetailBubbleTapEventName
                     userInfo:@{KMESSAGEKEY:self.model}];
}

+(CGFloat)heightForBubbleWithObject:(HDMessage *)object
{
    return 4 * BUBBLE_VIEW_PADDING + 45.f;
}


@end
