//
//  HDTextMessageBody.h
//  AgentSDK
//
//  Created by afanda on 9/7/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "HDBaseMessageBody.h"

@interface HDTextMessageBody : HDBaseMessageBody

/**
 文本内容
 */
@property (nonatomic, copy) NSString *text;

/**
 初始化文本消息

 @param text 文本内容
 @return 文本消息体实例
 */
- (instancetype)initWithText:(NSString *)text;

@end
