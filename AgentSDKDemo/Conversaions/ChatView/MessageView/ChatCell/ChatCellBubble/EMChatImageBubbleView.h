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

#import <UIKit/UIKit.h>

#import "EMChatBaseBubbleView.h"

#define MAX_SIZE 120 //　图片最大显示大小

@class BubbleArrowImageView;
extern NSString *const kRouterEventImageBubbleTapEventName;

@interface EMChatImageBubbleView : EMChatBaseBubbleView
@property (nonatomic, strong) BubbleArrowImageView *imageView;
@end

@interface BubbleArrowImageView : UIView
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL isLeft;
- (void)setImageWithURL:(NSURL *)aImageURL placeholderImage:(UIImage *)aPlaceholderImage;
@end
