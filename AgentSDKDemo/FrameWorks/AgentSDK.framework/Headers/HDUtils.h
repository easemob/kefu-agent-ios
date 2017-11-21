//
//  HDUtils.h
//  AgentSDK
//
//  Created by afanda on 9/14/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HDExtMsgType) {
    HDExtMsgTypeGeneral = 0, //正常消息
    HDExtMsgTypeMenu , //菜单消息
    HDExtMsgTypeTrack, //轨迹消息
    HDExtMsgTypeOrder, //订单消息
    HDExtMsgTypeForm //表单消息
};

@interface HDUtils : NSObject

+ (HDExtMsgType)getMessageExtType:(HDMessage *)message;

//是菜单消息
+ (BOOL)isMenuMessage:(NSDictionary *)ext;

//是轨迹消息
+ (BOOL)isTrackMessage:(NSDictionary *)ext;

//是订单消息
+ (BOOL)isOrderMessage:(NSDictionary *)ext;



@end
