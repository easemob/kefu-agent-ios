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

@implementation HDFormItem

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        if (dic == nil || [dic isKindOfClass:[NSNull class]]) {
            return self;
        }
        NSDictionary *msgtype = [dic objectForKey:@"msgtype"];
        if (msgtype) {
            NSDictionary *html = [msgtype objectForKey:@"html"];
            if (html) {
                _topic = [html objectForKey:@"topic"];
                _desc = [html objectForKey:@"desc"];
                _url = [html objectForKey:@"url"];
            }
        }
    }
    return self;
}

@end

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
        _desLabel.textColor = [UIColor lightTextColor];
        _desLabel.textAlignment = NSTextAlignmentLeft;
        _desLabel.font = [UIFont systemFontOfSize:12.f];
        _desLabel.numberOfLines = 2;
        [self addSubview:_desLabel];
        
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.frame = CGRectMake(0, 0,self.height , self.height );
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(_imageView.frame)+BUBBLE_VIEW_PADDING, BUBBLE_VIEW_PADDING, self.width-self.height-2*BUBBLE_VIEW_PADDING, 20);
    self.desLabel.frame = CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMaxY(self.titleLabel.frame), CGRectGetWidth(self.titleLabel.frame), 30);
    
}


- (CGSize)sizeThatFits:(CGSize)size {
     CGSize retSize = CGSizeMake(MAX_WIDTH, 75.f);
     return CGSizeMake(retSize.width + BUBBLE_VIEW_PADDING * 2 + BUBBLE_ARROW_WIDTH, retSize.height);
}


- (void)setModel:(HDMessage *)model {
    [super setModel:model];
    HDFormItem *item = [[HDFormItem alloc] initWithDictionary:model.nBody.msgExt];
    _item = item;
    if (item == nil) {
        return;
    }
    self.titleLabel.text = item.topic;
    self.desLabel.text = item.desc;
}

-(void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventFormBubbleTapEventName
                     userInfo:@{KMESSAGEKEY:_item}];
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
