//
//  EMChatImageTextBubbleView.m
//  EMCSApp
//
//  Created by EaseMob on 15/5/28.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "EMChatImageTextBubbleView.h"

#import "UIImageView+EMWebCache.h"

#define kLabelHeight 16.f
#define kLabelFont 16.f

#define kSpaceTop 11.f
#define kSpaceLeft 6.f

#define kNameLabelWidth 120.f

#define kImageViewWidth 50.f

#define kTextColor RGBACOLOR(0xce, 0xce, 0xce, 1)

#define kViewSpace 5.f

NSString *const kRouterEventImageTextBubbleTapEventName = @"kRouterEventImageTextBubbleTapEventName";

@interface EMChatImageTextBubbleView ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *orderTitleLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *priceLabel;

@end

@implementation EMChatImageTextBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = 2;
        [self addSubview:_imageView];
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.hidden = YES;
        _priceLabel.textColor = RGBACOLOR(255, 106, 0, 1);
        _priceLabel.textAlignment = NSTextAlignmentLeft;
        _priceLabel.font = [UIFont systemFontOfSize:20];
        [self addSubview:_priceLabel];
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.hidden = YES;
        _nameLabel.textColor = RGBACOLOR(0x1a, 0x1a, 0x1a, 1);
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont systemFontOfSize:12.f];
        _nameLabel.numberOfLines = 2;
//        _nameLabel.backgroundColor = [UIColor redColor];
        [self addSubview:_nameLabel];
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.hidden = YES;
        _titleLabel.textColor = RGBACOLOR(0x1a, 0x1a, 0x1a, 1);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:kLabelFont];
        _titleLabel.numberOfLines = 2;
        _titleLabel.text = @"我正在看:";
        [self addSubview:_titleLabel];
        _orderTitleLabel = [[UILabel alloc] init];
        _orderTitleLabel.hidden = YES;
        _orderTitleLabel.textColor = RGBACOLOR(0x1a, 0x1a, 0x1a, 1);
        _orderTitleLabel.textAlignment = NSTextAlignmentLeft;
        _orderTitleLabel.font = [UIFont systemFontOfSize:kLabelFont];
        [self addSubview:_orderTitleLabel];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize retSize = CGSizeMake(MAX_WIDTH, MAX_WIDTH);
    if (self.model.ext) {
        retSize.height = 115;
        if (self.model.ext.msgtype.orderTitle && self.model.ext.msgtype.orderTitle.length > 0) {
            NSString *string = [NSString stringWithFormat:@"%@ %@",self.model.ext.msgtype.title,self.model.ext.msgtype.desc];
            NSDictionary *attributes = @{NSFontAttributeName :[UIFont systemFontOfSize:kLabelFont]};
            CGRect rect = [string boundingRectWithSize:CGSizeMake(kNameLabelWidth, MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:attributes
                                               context:nil];
            CGFloat height = CGRectGetHeight(rect);
            if (height > 30) {
                retSize.height += kLabelHeight + kViewSpace;
            }
        }
    }
    
    return CGSizeMake(retSize.width + BUBBLE_VIEW_PADDING * 2 + BUBBLE_ARROW_WIDTH, retSize.height);
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
    if (self.model.ext) {
        self.titleLabel.frame = CGRectMake(BUBBLE_RIGHT_LEFT_CAP_WIDTH + kViewSpace * 2, kViewSpace, CGRectGetWidth(frame), kLabelHeight);
        if (self.model.ext.msgtype.orderTitle.length > 0) {
            NSString *string = [NSString stringWithFormat:@"%@",self.model.ext.msgtype.title];
            NSDictionary *attributes = @{NSFontAttributeName :[UIFont systemFontOfSize:kLabelFont]};
            CGRect rect = [string boundingRectWithSize:CGSizeMake(kNameLabelWidth, MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:attributes
                                               context:nil];
            CGFloat height = CGRectGetHeight(rect);
            if (height > 30) {
                self.titleLabel.height += kLabelHeight + kViewSpace;
            }
        }
        self.imageView.frame = CGRectMake(BUBBLE_RIGHT_LEFT_CAP_WIDTH + kSpaceLeft, CGRectGetMaxY(self.titleLabel.frame) + kViewSpace, 80, 80);
        if (self.model.ext.msgtype.orderTitle.length > 0) {
            _orderTitleLabel.frame = CGRectMake(BUBBLE_RIGHT_LEFT_CAP_WIDTH + kViewSpace * 2, CGRectGetMaxY(self.titleLabel.frame) + kViewSpace, CGRectGetWidth(frame), kLabelHeight);
            self.imageView.top = CGRectGetMaxY(_orderTitleLabel.frame) + 5;
        }
        self.nameLabel.frame = CGRectMake(CGRectGetMaxX(_imageView.frame) + kViewSpace * 2, CGRectGetMinY(_imageView.frame)+5, kNameLabelWidth, 40);
        self.priceLabel.frame = CGRectMake(CGRectGetMaxX(_imageView.frame) + kViewSpace * 2, CGRectGetMaxY(_imageView.frame) - 18, kNameLabelWidth, 20);
    } else {
        [self.imageView setFrame:frame];
    }
}

#pragma mark - setter

- (void)setModel:(HDMessage *)model
{
    [super setModel:model];
    
    UIImage *image = _model.isSender ? _model.image : _model.thumbnailImage;
    if (!image) {
        image = _model.image;
        self.imageView.image = image;
        if (!image) {
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",model.ext.msgtype.imgUrl]] placeholderImage:[UIImage imageNamed:@"visitor_icon_imagebroken"] completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    
                }
                
            }];
        }
    } else {
        self.imageView.image = image;
    }
    if (model.ext) {
        if (model.ext.msgtype.price.length > 0) {
            _priceLabel.hidden = NO;
            _priceLabel.text = self.model.ext.msgtype.price;
        } else {
            _priceLabel.hidden = YES;
        }
        if (model.ext.msgtype.desc.length > 0) {
            _nameLabel.hidden = NO;
            _nameLabel.text = self.model.ext.msgtype.desc;
        } else {
            _nameLabel.hidden = YES;
        }
        if (model.ext.msgtype.orderTitle.length > 0) {
            _titleLabel.text = self.model.ext.msgtype.title;
            _orderTitleLabel.text = self.model.ext.msgtype.orderTitle;
            _orderTitleLabel.hidden = NO;
        } else {
            _titleLabel.text = [NSString stringWithFormat:@"%@",self.model.ext.msgtype.title];
            _orderTitleLabel.hidden = YES;
        }

        _titleLabel.hidden = NO;
    } else {
        _priceLabel.hidden = YES;
        _nameLabel.hidden = YES;
        _titleLabel.hidden = YES;
    }
}

#pragma mark - public

-(void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventImageTextBubbleTapEventName
                     userInfo:@{KMESSAGEKEY:self.model}];
}


+(CGFloat)heightForBubbleWithObject:(HDMessage *)object
{
    CGSize retSize = CGSizeMake(MAX_WIDTH, MAX_WIDTH);;
    if (object.ext) {
        retSize.height = 115;
        if (object.ext.msgtype.orderTitle && object.ext.msgtype.orderTitle.length > 0) {
            NSString *string = [NSString stringWithFormat:@"%@ %@",object.ext.msgtype.title,object.ext.msgtype.desc];
            NSDictionary *attributes = @{NSFontAttributeName :[UIFont systemFontOfSize:kLabelFont]};
            CGRect rect = [string boundingRectWithSize:CGSizeMake(kNameLabelWidth, MAXFLOAT)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:attributes
                                                                    context:nil];
            CGFloat height = CGRectGetHeight(rect);
            if (height > 30) {
                retSize.height += kLabelHeight + kViewSpace;
            }
        }
    }
    return 2 * BUBBLE_VIEW_PADDING + retSize.height;
}

@end
