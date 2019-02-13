//
//  ConvertToCommonEmoticonsHelper.m
//  EMCSApp
//
//  Created by EaseMob on 15/4/16.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "ConvertToCommonEmoticonsHelper.h"
#import "Emoji.h"

@implementation ConvertToCommonEmoticonsHelper

+ (NSArray*)emotionsArray
{
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:@"[):]"];
    [array addObject:@"[:D]"];
    [array addObject:@"[;)]"];
    [array addObject:@"[:-o]"];
    [array addObject:@"[:p]"];
    [array addObject:@"[(H)]"];
    [array addObject:@"[:@]"];
    [array addObject:@"[:s]"];
    [array addObject:@"[:$]"];
    [array addObject:@"[:(]"];
    [array addObject:@"[:'(]"];
    [array addObject:@"[:|]"];
    [array addObject:@"[(a)]"];
    [array addObject:@"[8o|]"];
    [array addObject:@"[8-|]"];
    [array addObject:@"[+o(]"];
    [array addObject:@"[<o)]"];
    [array addObject:@"[|-)]"];
    [array addObject:@"[*-)]"];
    [array addObject:@"[:-#]"];
    [array addObject:@"[:-*]"];
    [array addObject:@"[^o)]"];
    [array addObject:@"[8-)]"];
    [array addObject:@"[(|)]"];
    [array addObject:@"[(u)]"];
    [array addObject:@"[(S)]"];
    [array addObject:@"[(*)]"];
    [array addObject:@"[(#)]"];
    [array addObject:@"[(R)]"];
    [array addObject:@"[(})]"];
    [array addObject:@"[({)]"];
    [array addObject:@"[(k)]"];
    [array addObject:@"[(F)]"];
    [array addObject:@"[(W)]"];
    [array addObject:@"[(D)]"];
    
    return array;
    
}

+ (NSDictionary *)emotionsDictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"ee_1" forKey:@"[):]"];
    [dic setObject:@"ee_2" forKey:@"[:D]"];
    [dic setObject:@"ee_3" forKey:@"[;)]"];
    [dic setObject:@"ee_4" forKey:@"[:-o]"];
    [dic setObject:@"ee_5" forKey:@"[:p]"];
    [dic setObject:@"ee_6" forKey:@"[(H)]"];
    [dic setObject:@"ee_7" forKey:@"[:@]"];
    [dic setObject:@"ee_8" forKey:@"[:s]"];
    [dic setObject:@"ee_9" forKey:@"[:$]"];
    [dic setObject:@"ee_10" forKey:@"[:(]"];
    [dic setObject:@"ee_11" forKey:@"[:'(]"];
    [dic setObject:@"ee_12" forKey:@"[:|]"];
    [dic setObject:@"ee_13" forKey:@"[(a)]"];
    [dic setObject:@"ee_14" forKey:@"[8o|]"];
    [dic setObject:@"ee_15" forKey:@"[8-|]"];
    [dic setObject:@"ee_16" forKey:@"[+o(]"];
    [dic setObject:@"ee_17" forKey:@"[<o)]"];
    [dic setObject:@"ee_18" forKey:@"[|-)]"];
    [dic setObject:@"ee_19" forKey:@"[*-)]"];
    [dic setObject:@"ee_20" forKey:@"[:-#]"];
    [dic setObject:@"ee_21" forKey:@"[:-*]"];
    [dic setObject:@"ee_22" forKey:@"[^o)]"];
    [dic setObject:@"ee_23" forKey:@"[8-)]"];
    [dic setObject:@"ee_24" forKey:@"[(|)]"];
    [dic setObject:@"ee_25" forKey:@"[(u)]"];
    [dic setObject:@"ee_26" forKey:@"[(S)]"];
    [dic setObject:@"ee_27" forKey:@"[(*)]"];
    [dic setObject:@"ee_28" forKey:@"[(#)]"];
    [dic setObject:@"ee_29" forKey:@"[(R)]"];
    [dic setObject:@"ee_30" forKey:@"[({)]"];
    [dic setObject:@"ee_31" forKey:@"[(})]"];
    [dic setObject:@"ee_32" forKey:@"[(k)]"];
    [dic setObject:@"ee_33" forKey:@"[(F)]"];
    [dic setObject:@"ee_34" forKey:@"[(W)]"];
    [dic setObject:@"ee_35" forKey:@"[(D)]"];
    
    return dic;
}

#pragma mark - emotics
+ (NSString *)convertToCommonEmoticons:(NSString *)text {
    return text;
}

+ (NSString *)convertToSystemEmoticons:(NSString *)text
{
    return text;
}

+ (NSString *)textFormat:(NSString *)text
{
    text = [text stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    return [text stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
}
@end
