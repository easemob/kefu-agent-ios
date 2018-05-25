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
        _imageView = [[BubbleArrowImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
        _imageView.backgroundColor = UIColor.clearColor;
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
    [self.imageView setFrame:frame];
}

#pragma mark - setter

- (void)setModel:(HDMessage *)model
{
    [super setModel:model];
    
    HDImageMessageBody *body = (HDImageMessageBody *)model.nBody;
    self.imageView.isLeft = !model.isSender;
    UIImage *image = nil;
    NSData *imgData = body.imageData;
    if (imgData != nil) {
        image = [UIImage imageWithData:body.imageData];
    }
    if (image == nil) {
        [self.imageView setImageWithURL:[NSURL URLWithString:body.remotePath]
                       placeholderImage:[UIImage imageNamed:@"visitor_icon_imagebroken_big"]];
    } else {
        self.imageView.image = image;
    }
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


#define kArrowWidth 5       // 尖角宽度
#define kArrowMarginTop 12  // 尖角距离顶部距离
#define kArrowHeight 12     // 尖角高度

@interface BubbleArrowImageView ()
{
    BOOL _isLeft;
}
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation BubbleArrowImageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView.frame = self.bounds;
    }
    
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.imageView];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.imageView.frame = self.bounds;
}

- (void)setImageWithURL:(NSURL *)aImageURL placeholderImage:(UIImage *)aPlaceholderImage; {
    self.image = aPlaceholderImage;
    [self.imageView sd_setImageWithURL:aImageURL
                      placeholderImage:aPlaceholderImage
                             completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL)
     {
         if (!error) {
             self.image = image;
         }
    }];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self createArrowImage:image size:self.bounds.size isLeft:self.isLeft completion:^(UIImage *aImage) {
        dispatch_async(dispatch_get_main_queue(), ^{
           self.imageView.image = aImage;
        });
    }];
}

- (void)createArrowImage:(UIImage *)aImage size:(CGSize)aSize
                  isLeft:(BOOL)aIsLeft
              completion:(void(^)(UIImage *image))aCompletion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIGraphicsBeginImageContextWithOptions(aSize, NO, 0.0);
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        CGFloat imageW = aSize.width;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, aSize.width - kArrowWidth, aSize.height) cornerRadius:6];
        if (aIsLeft) {
            [path moveToPoint:CGPointMake(kArrowWidth, 0)];
            [path addLineToPoint:CGPointMake(kArrowWidth, kArrowMarginTop)];
            [path addLineToPoint:CGPointMake(0, kArrowMarginTop + 0.5 * kArrowHeight)];
            [path addLineToPoint:CGPointMake(kArrowWidth, kArrowMarginTop + kArrowHeight)];
        }else {
            [path moveToPoint:CGPointMake(imageW - kArrowWidth, 0)];
            [path addLineToPoint:CGPointMake(imageW - kArrowWidth, kArrowMarginTop)];
            [path addLineToPoint:CGPointMake(imageW, kArrowMarginTop + 0.5 * kArrowHeight)];
            [path addLineToPoint:CGPointMake(imageW - kArrowWidth, kArrowMarginTop + kArrowHeight)];
        }
        [path closePath];
        CGContextAddPath(contextRef, path.CGPath);
        CGContextEOClip(contextRef);
        [aImage drawInRect:CGRectMake(0, 0, aSize.width, aSize.height)];
        UIImage * arrowImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (aCompletion) {
            aCompletion(arrowImage);
        }
    });
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return _imageView;
}
@end
