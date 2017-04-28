//
//  HDPlaneBubbleView.m
//  AgentSDKDemo
//
//  Created by afanda on 4/27/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "HDPlaneBubbleView.h"

#define kTitleHeight 20
#define kTitleFontSize 20
#define kDetailFontSize 15
#define kBubbleWidth 200
#define kDetailWidth 120
#define kImageViewWH 40
#define kMargin 10
@interface HDPlaneBubbleView ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation HDPlaneBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = RGBACOLOR(255, 106, 0, 1);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:20];
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        [self addSubview:_titleLabel];
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.textColor = RGBACOLOR(0x1a, 0x1a, 0x1a, 1);
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _detailLabel.font = [UIFont systemFontOfSize:kDetailFontSize];
        _detailLabel.numberOfLines = 0;
        [self addSubview:_detailLabel];
    }
    return self;
}


- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(kBubbleWidth, [HDPlaneBubbleView heightForBubbleWithObject:self.model]);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    frame.size.width -= BUBBLE_ARROW_WIDTH;
    frame = CGRectInset(frame, 5, 5);
    
    if (self.model.isSender) {
        frame.origin.x = 5;
    }else{
        frame.origin.x = 5 + BUBBLE_ARROW_WIDTH;
    }
    frame.origin.y = 5;
    
    self.titleLabel.frame = CGRectMake(kMargin, 5, frame.size.width-BUBBLE_ARROW_WIDTH-2*kMargin, 16);
    self.detailLabel.frame = CGRectMake(kMargin, CGRectGetMaxY(self.titleLabel.frame)+kMargin, kDetailWidth,[self heightForDetail:self.model]);
    self.imageView.frame = CGRectMake(CGRectGetMaxX(self.detailLabel.frame)+5, CGRectGetMaxY(self.titleLabel.frame)+5, kImageViewWH, kImageViewWH);
}
- (void)setModel:(MessageModel *)model {
    [super setModel:model];
    
    NSDictionary *ext = model.body.msgExt;
    NSString *title = [ext objectForKey:@"planTitle"];
    NSString *detail = [ext objectForKey:@"planDesc"];
    NSString *imageUrl = [ext objectForKey:@"planPicUrl"];
    if (ext && imageUrl) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"visitor_icon_imagebroken_big"]];
    } else {
        self.imageView.image = [UIImage imageNamed:@"visitor_icon_imagebroken_big"];
    }
    _titleLabel.text = title;
    _detailLabel.text = detail;
}





+(CGFloat)heightForBubbleWithObject:(MessageModel *)object
{
    CGSize retSize = CGSizeMake(kBubbleWidth, 80);
    CGRect rect;
    NSDictionary *ext = object.body.msgExt;
    if (object.body.msgExt) {
        retSize.height = 115;
        NSString *detail = [ext objectForKey:@"planDesc"];
        if (ext && detail) {
            rect = [detail boundingRectWithSize:CGSizeMake(kDetailWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:kDetailFontSize]} context:nil];
        }
    }
    CGFloat detailH = rect.size.height;
    if (detailH<40) {
        detailH = 40 ;
    }
    return 2*kMargin+kTitleHeight+detailH ;
}


- (CGFloat)heightForDetail:(MessageModel *)model {
    CGRect rect;
    if (model.body.msgExt) {
        NSString *detail = [model.body.msgExt objectForKey:@"planDesc"];
        if (model.body.msgExt && detail) {
            rect = [detail boundingRectWithSize:CGSizeMake(kDetailWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:kDetailFontSize]} context:nil];
        }
    }
    return rect.size.height;
}

@end
