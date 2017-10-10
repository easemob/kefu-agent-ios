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

#import "UIImageView+EMWebCache.h"
#import "EMChatImageBubbleView.h"

NSString *const kRouterEventImageBubbleTapEventName = @"kRouterEventImageBubbleTapEventName";

@interface EMChatImageBubbleView ()

@end

@implementation EMChatImageBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.masksToBounds = YES;
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
        [self addSubview:_imageView];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize retSize;
    if (self.model.ext) {
        retSize = CGSizeMake(0, 0);
    } else {
        retSize = CGSizeMake(0, 0);
    }
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = MAX_SIZE;
        retSize.height = MAX_SIZE;
    }
    if (retSize.width > retSize.height) {
        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
        retSize.height = height;
        retSize.width = MAX_SIZE;
    }else {
        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
        retSize.width = width;
        retSize.height = MAX_SIZE;
    }
    if (self.model.ext) {
        retSize.height = MAX_SIZE / 4 * 3;
    }
    
    return CGSizeMake(retSize.width + BUBBLE_VIEW_PADDING * 2 + BUBBLE_ARROW_WIDTH,2 * BUBBLE_VIEW_PADDING + retSize.height);
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame.size.width -= BUBBLE_ARROW_WIDTH;
    frame = CGRectInset(frame, 5, 5);
    if (self.model.isSender) {
        frame.origin.x = 5;
    }else{
        frame.origin.x = 5 + BUBBLE_ARROW_WIDTH;
    }
//
    frame.origin.y = 5;
    [self.imageView setFrame:frame];
}

#pragma mark - setter

- (void)setModel:(HDMessage *)model
{
    [super setModel:model];
    
    HDImageMessageBody *body = (HDImageMessageBody *)model.nBody;
    
    UIImage *image = nil;
    NSData *imgData = body.imageData;
    if (imgData != nil) {
        image = [UIImage imageWithData:body.imageData];
    }
    if (image == nil) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:body.remotePath] placeholderImage:[UIImage imageNamed:@"visitor_icon_imagebroken_big"] completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                
            }
        }];
    } else {
        self.imageView.image = image;
    }
    
//    if (!image) {
//        image = _model.image;
//        self.imageView.image = image;
//        if (!image) {
//            [self.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseURL,model.body.originalPath]] placeholderImage:[UIImage imageNamed:@"visitor_icon_imagebroken_big"] completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
//                if (image) {
//                
//                }
//                
//            }];
//        }
//    } else {
//        self.imageView.image = image;
//    }
}

#pragma mark - public

-(void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventImageBubbleTapEventName
                     userInfo:@{KMESSAGEKEY:self.model}];
}


+(CGFloat)heightForBubbleWithObject:(HDMessage *)object
{
    CGSize retSize;
    if (object.ext) {
        retSize = CGSizeMake(0, 0);
    } else {
        retSize = CGSizeMake(0, 0);
    }
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = MAX_SIZE;
        retSize.height = MAX_SIZE;
    }else if (retSize.width > retSize.height) {
        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
        retSize.height = height;
        retSize.width = MAX_SIZE;
    }else {
        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
        retSize.width = width;
        retSize.height = MAX_SIZE;
    }
    if (object.ext) {
        retSize.height = MAX_SIZE / 4 * 3;
    }
    return 4 * BUBBLE_VIEW_PADDING + retSize.height;
}

@end
