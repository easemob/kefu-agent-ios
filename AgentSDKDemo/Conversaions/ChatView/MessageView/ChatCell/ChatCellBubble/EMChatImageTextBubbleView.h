//
//  EMChatImageTextBubbleView.h
//  EMCSApp
//
//  Created by EaseMob on 15/5/28.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "EMChatBaseBubbleView.h"

#define MAX_WIDTH 200 //　图片最大显示大小

extern NSString *const kRouterEventImageTextBubbleTapEventName;

@interface EMChatImageTextBubbleView : EMChatBaseBubbleView

@property (nonatomic, strong) UIImageView *imageView;

@end
