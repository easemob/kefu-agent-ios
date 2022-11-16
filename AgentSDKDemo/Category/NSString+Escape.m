//
//  NSString+Escape.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/1.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "NSString+Escape.h"

@implementation NSString (Escape)

+(CGFloat)widthOfString:(NSString *)string font:(CGFloat)fontSize height:(CGFloat)height
{
    NSDictionary * dict=[NSDictionary dictionaryWithObject: [UIFont systemFontOfSize:fontSize] forKey:NSFontAttributeName];
    CGRect rect=[string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    return rect.size.width;
}

+(CGFloat)heightOfString:(NSString *)string font:(CGFloat)fontSize width:(CGFloat)width
{
    CGRect bounds;
    NSDictionary * parameterDict=[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontSize] forKey:NSFontAttributeName];
    bounds=[string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:parameterDict context:nil];
    return bounds.size.height;
}

- (NSString *)encodeToPercentEscapeString
{
    NSString *outputStr = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, /* allocator */
                                                                                       (__bridge CFStringRef)self,
                                                                                       NULL, /* charactersToLeaveUnescaped */
                                                                                       (CFStringRef)@"!*'();:@&=+$,?%#[]",
                                                                                       kCFStringEncodingUTF8);
    return outputStr;
}

+ (NSString *)htmlToString:(NSString *)html {
    NSScanner *theScaner = [NSScanner scannerWithString:html];
    NSDictionary *dict = @{@"&amp;":@"<", @"&lt;":@"<", @"&gt;":@">", @"&nbsp;":@"", @"&quot;":@"\"", @"width":@"wid"};
    while ([theScaner isAtEnd] == NO) {
        for (int i = 0; i <[dict allKeys].count; i ++) {
            [theScaner scanUpToString:[dict allKeys][i] intoString:NULL];
            html = [html stringByReplacingOccurrencesOfString:[dict allKeys][i] withString:[dict allValues][i]];
        }
    }
    return html;
}


#pragma mark - url 编码
- (NSString *)URLEncodedString {
    NSString *encodedString = [self stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@"!@$^&%*+,;='\"`<>()[]{}\\| "] invertedSet]];
    return encodedString;
}
#pragma mark - url 解码
-(NSString *)URLDecodedString
{
NSString *result = [(NSString *)self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
return [result stringByRemovingPercentEncoding];
}
@end
