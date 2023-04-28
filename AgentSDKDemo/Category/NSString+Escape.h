//
//  NSString+Escape.h
//  EMCSApp
//
//  Created by EaseMob on 16/3/1.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Escape)


//字符串文字的长度
+(CGFloat)widthOfString:(NSString *)string font:(CGFloat)fontSize height:(CGFloat)height;

//字符串文字的高度
+(CGFloat)heightOfString:(NSString *)string font:(CGFloat)fontSize width:(CGFloat)width;

- (NSString *)encodeToPercentEscapeString;

+ (NSString *)htmlToString:(NSString *)html;
- (NSString *)URLEncodedString;
-(NSString *)URLDecodedString;
@end
