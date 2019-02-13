//
//  HDChatFormBubbleView.h
//  AgentSDKDemo
//
//  Created by afanda on 11/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "EMChatBaseBubbleView.h"

@interface HDFormItem :NSObject
@property (nonatomic, strong) NSString *topic;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *url;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end


extern NSString *const kRouterEventFormBubbleTapEventName;

@interface HDChatFormBubbleView : EMChatBaseBubbleView

@property (nonatomic, strong) HDFormItem *item;
@end
