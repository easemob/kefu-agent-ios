//
//  HDCMDMessageBody.h
//  AgentSDK
//
//  Created by houli on 2022/6/21.
//  Copyright © 2022 环信. All rights reserved.
//

#import "HDBaseMessageBody.h"

NS_ASSUME_NONNULL_BEGIN

@interface HDCMDMessageBody : HDBaseMessageBody
/**
 文本内容
 */
@property (nonatomic, copy) NSString *msg;

/**
 初始化cmd消息

 @param mas 文本内容
 @return 文本消息体实例
 */
- (instancetype)initWithMsg:(NSString *)msg;
@end

NS_ASSUME_NONNULL_END
