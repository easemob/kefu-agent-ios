//
//  EMChatFileBubbleView.m
//  EMCSApp
//
//  Created by EaseMob on 16/2/17.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMChatFileBubbleView.h"

#define kLabelFont 16.f

#define MAX_WIDTH 240

NSString *const kRouterEventFileBubbleTapEventName = @"kRouterEventFileBubbleTapEventName";

@interface EMChatFileBubbleView ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *sizeLabel;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation EMChatFileBubbleView

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
        _imageView.image = [UIImage imageNamed:@"image_file2_icon_files"];
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
    self.nameLabel.text = ((HDFileMessageBody *)model.nBody).displayName;
    CGFloat fileSize = ((HDFileMessageBody *)model.nBody).fileLength/1024.0;
    if (fileSize > 0){
        self.sizeLabel.text = [NSString stringWithFormat:@"%.2f kb",fileSize];
    }else{
        self.sizeLabel.text = @"";
    }
    
}

#pragma mark - public

-(void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventFileBubbleTapEventName
                     userInfo:@{KMESSAGEKEY:self.model}];
}

+(CGFloat)heightForBubbleWithObject:(HDMessage *)object
{
    return 4 * BUBBLE_VIEW_PADDING + 75.f;
}

@end
