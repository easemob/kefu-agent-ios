//
//  HDUtils.h
//  AgentSDK
//
//  Created by afanda on 9/14/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgentSDKTypes.h"
#import "HDEncryptUtil.h"
@interface HDUtils : NSObject

+ (HDExtMsgType)getMessageExtType:(HDMessage *)message;

//是菜单消息
+ (BOOL)isMenuMessage:(NSDictionary *)ext;

//是轨迹消息
+ (BOOL)isTrackMessage:(NSDictionary *)ext;

//是订单消息
+ (BOOL)isOrderMessage:(NSDictionary *)ext;

//是录像消息
+ (BOOL)isVideoPlaybackMessage:(NSDictionary *)ext ;
+ (NSDictionary *)dictionaryWithString:(NSString *)string;
+ (BOOL)isNSDictionary:(NSDictionary *)dic;
+ (BOOL)canObjectForKey:(id)obj;
+ (BOOL)isVisitorCancelInvitationMessage:(NSDictionary *)ext;

@end
