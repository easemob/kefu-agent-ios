//
//  HDChatFormBubbleView.m
//  AgentSDKDemo
//
//  Created by afanda on 11/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "HDChatFormBubbleView.h"

#define kLabelFont 16.f

#define MAX_WIDTH 240

NSString *const kRouterEventFormBubbleTapEventName = @"kRouterEventFormBubbleTapEventName";

@interface HDChatFormBubbleView ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *desLabel;

@end


@implementation HDChatFormBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.image = [UIImage imageNamed:@"chat_item_form"];
        [self addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = RGBACOLOR(0x1a, 0x1a, 0x1a, 1);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:kLabelFont];
        _titleLabel.numberOfLines = 2;
        [self addSubview:_titleLabel];
        _desLabel = [[UILabel alloc] init];
        _desLabel.textColor = RGBACOLOR(0x1a, 0x1a, 0x1a, 1);
        _desLabel.textAlignment = NSTextAlignmentLeft;
        _desLabel.font = [UIFont systemFontOfSize:kLabelFont];
        _desLabel.numberOfLines = 2;
        _desLabel.text = @"";
        [self addSubview:_desLabel];
        
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
    self.titleLabel.frame = frame;
    self.desLabel.frame = CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMaxY(self.titleLabel.frame), CGRectGetWidth(self.titleLabel.frame), 30);
    
}


- (CGSize)sizeThatFits:(CGSize)size {
     CGSize retSize = CGSizeMake(MAX_WIDTH, 75.f);
     return CGSizeMake(retSize.width + BUBBLE_VIEW_PADDING * 2 + BUBBLE_ARROW_WIDTH, retSize.height);
}


- (void)setModel:(HDMessage *)model {
    [super setModel:model];
    self.titleLabel.text = @"1234567";
    self.desLabel.text = @"jdjdadfdasfda";
}

-(void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventFormBubbleTapEventName
                     userInfo:@{KMESSAGEKEY:self.model}];
}

+(CGFloat)heightForBubbleWithObject:(HDMessage *)object
{
    return 4 * BUBBLE_VIEW_PADDING + 75.f;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
