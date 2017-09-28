//
//  ChatSendHelper.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/16.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ChatSendHelper : NSObject

+(HDMessage *)sendTextMessageWithString:(NSString *)str toUser:(NSString *)userId sessionId:(NSString*)sessionId ext:(NSDictionary*)ext;

#pragma mark - new
///---- 同事之间
//客服文本
+ (HDMessage *)customerTextMessageFormatWithText:(NSString *)text to:(NSString *)toUser;
//客服图片
+ (HDMessage *)customerImageMessageFormatWithImageData:(NSData *)imageData to:(NSString *)toUser;

//---- 访客与客服之间
//文本消息
+ (HDMessage *)textMessageFormatWithText:(NSString *)text to:(NSString *)toUser sessionId:(NSString *)sessionId;
//图片消息
+ (HDMessage *)imageMessageFormatWithImageData:(NSData *)data to:(NSString *)toUser sessionId:(NSString *)sessionId;
//语音消息

+ (HDMessage *)voiceMessageFormatWithPath:(NSString *)path to:(NSString *)toUser  sessionId:(NSString *)sessionId;


@end
