//
//  KFSmartUtils.h
//  AgentSDKDemo
//
//  Created by houli on 2022/5/20.
//  Copyright © 2022 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KFSmartUtils : NSObject
//是菜单消息
+ (BOOL)isMenuMessage:(NSDictionary *)ext;

//是图文消息
+ (BOOL)isArticleMessage:(NSDictionary *)ext;

//是文本消息
+ (BOOL)isTextMessage:(NSDictionary *)ext;

//是图片消息
+ (BOOL)isImageMessage:(NSDictionary *)ext;


//是文本消息
+ (BOOL)isTextMessageStr:(NSString *)ext;
//是菜单消息
+ (BOOL)isMenuMessageStr:(NSString *)ext;
//是图文消息
+ (BOOL)isArticleMessageStr:(NSString *)ext;
//是答案组 消息
+ (BOOL)isGroupMessageStr:(NSString *)ext;
//是图片 消息
+ (BOOL)isImgMessageStr:(NSString *)ext;

//是html消息
+ (BOOL)isHtmlMessage:(HDMessage *)message;
+ (NSDictionary *)dictionaryWithString:(NSString *)string;
+ (BOOL)isJsonString:(NSString *)jsonString;
@end

NS_ASSUME_NONNULL_END
