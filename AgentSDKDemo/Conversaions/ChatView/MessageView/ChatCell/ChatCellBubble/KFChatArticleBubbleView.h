//
//  KFChatArticleBubbleView.h
//  AgentSDKDemo
//
//  Created by houli on 2022/5/27.
//  Copyright © 2022 环信. All rights reserved.
//

#import "EMChatBaseBubbleView.h"

NS_ASSUME_NONNULL_BEGIN
#define MAX_WIDTH 200 //　图片最大显示大小
#define MAX_SIZE 120 //　图片最大显示大小
extern NSString *const kRouterEventArticleBubbleTapEventName;

@interface KFChatArticleBubbleView : EMChatBaseBubbleView
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) UIImageView *imageView;

+ (CGFloat)heightForBubbleWithObject:(HDMessage *)object;
@end

NS_ASSUME_NONNULL_END
