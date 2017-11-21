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
#import "THProgressView.h"
#import "UIResponder+Router.h"

extern NSString *const kRouterEventChatCellBubbleTapEventName;

#define BUBBLE_LEFT_IMAGE_NAME @"message_agent_1_chatpop_agent" // bubbleView 的背景图片
#define BUBBLE_RIGHT_IMAGE_NAME @"message_agent_2_chatpop_agent"
#define BUBBLE_ARROW_WIDTH 9 // bubbleView中，箭头的宽度
#define BUBBLE_VIEW_PADDING 11 // bubbleView 与 在其中的控件内边距

#define BUBBLE_RIGHT_LEFT_CAP_WIDTH 9 // 文字在右侧时,bubble用于拉伸点的X坐标
#define BUBBLE_RIGHT_TOP_CAP_HEIGHT 27 // 文字在右侧时,bubble用于拉伸点的Y坐标

#define BUBBLE_LEFT_LEFT_CAP_WIDTH 27 // 文字在左侧时,bubble用于拉伸点的X坐标
#define BUBBLE_LEFT_TOP_CAP_HEIGHT 27 // 文字在左侧时,bubble用于拉伸点的Y坐标

#define BUBBLE_PROGRESSVIEW_HEIGHT 10 // progressView 高度

#define KMESSAGEKEY @"message"

@interface EMChatBaseBubbleView : UIView< UIGestureRecognizerDelegate>
{
    THProgressView *_progressView;
    HDMessage *_model;
}

@property (nonatomic, strong) HDMessage *model;

@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) THProgressView *progressView;

- (void)bubbleViewPressed:(id)sender;

+ (CGFloat)heightForBubbleWithObject:(HDMessage *)object;

@end
