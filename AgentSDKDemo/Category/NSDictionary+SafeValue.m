//
//  NSDictionary+SafeValue.m
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "NSDictionary+SafeValue.h"

@implementation NSDictionary (SafeValue)

- (NSString *)safeStringValueForKey:(NSString *)key
{
    NSString *safeString = @"";
    id value = [self objectForKey:key];
    
    do {
        if (value == [NSNull null] || value == nil) {
            break;
        }
        
        if ([value isKindOfClass:[NSString class]]) {
            safeString = (NSString *)value;
            break;
        }
        
        if ([value isKindOfClass:[NSNumber class]]) {
            safeString = [value stringValue];
            break;
        }
        
        safeString = [value stringValue];
    } while (0);
    
    return safeString;
}

- (NSInteger)safeIntegerValueForKey:(NSString *)key
{
    NSInteger safeInteger = 0;
    id value = [self objectForKey:key];
    
    do {
        if (value == [NSNull null] || value == nil) {
            break;
        }
        
        if ([value isKindOfClass:[NSObject class]]) {
            safeInteger = [value integerValue];
            break;
        }
    } while (0);
    
    return safeInteger;
}

- (NSDictionary *)safeDictValueForKey:(NSString *)key {
    NSDictionary *ret = nil;
    do {
        id value = [self objectForKey:key];
        if (value == [NSNull null] || value == nil) {
            break;
        }
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            ret = value;
            break;
        }
    } while (0);
    
    return ret;
}
- (BOOL)isDictionaryContainsKey:(NSString *)key{
    if ([self.allKeys containsObject:key]) {
        
        return  YES;
    }
    return NO;
}
- (instancetype)getDictionaryValue:(NSString *)key{
    
    return [self valueForKey:key];
    
}
@end
