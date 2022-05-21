//
//  KFSmartUtils.m
//  AgentSDKDemo
//
//  Created by houli on 2022/5/20.
//  Copyright © 2022 环信. All rights reserved.
//

#import "KFSmartUtils.h"
@implementation KFSmartUtils

+ (BOOL)isMenuMessage:(NSDictionary *)ext {
    if (![KFSmartUtils canObjectForKey:ext]) {
        return NO;
    }
    
    NSDictionary *msgtype = [ext valueForKey:@"msgtype"];
    
    if ([KFSmartUtils canObjectForKey:msgtype]) {
        if ([KFSmartUtils canObjectForKey:[msgtype valueForKey:@"choice"]]) {
            return YES;
        }
    }
    return NO;
}
//+ (BOOL)isTextMessage:(NSDictionary *)ext{
//
//    if (![KFSmartUtils canObjectForKey:ext]) {
//        return NO;
//    }
//
//    NSDictionary *msgtype = [ext valueForKey:@"msgtype"];
//
//    if ([KFSmartUtils canObjectForKey:msgtype]) {
//        if ([KFSmartUtils canObjectForKey:[msgtype valueForKey:@"choice"]]) {
//            return YES;
//        }
//    }
//    return NO;
//
//}
+ (BOOL)isTextMessageStr:(NSString *)ext{
    
    if ([ext isEqualToString:@"txt"]) {
        
        return YES;
    }
    
    return NO;
}
+ (BOOL)isMenuMessageStr:(NSString *)ext{
    
    if ([ext isEqualToString:@"MENU"] || [ext isEqualToString:@"recommend"]) {
        
        return YES;
    }
    
    return NO;
}
+ (BOOL)isArticleMessageStr:(NSString *)ext{
   
    if ([ext isEqualToString:@"article"]) {
        
        return YES;
    }
    
    return NO;
    
}
+ (BOOL)isGroupMessageStr:(NSString *)ext{
   
    if ([ext isEqualToString:@"GROUP"]) {
        
        return YES;
    }
    
    return NO;
    
}
+ (BOOL)isImgMessageStr:(NSString *)ext{
   
    if ([ext isEqualToString:@"img"]) {
        
        return YES;
    }
    
    return NO;
    
}
+ (BOOL)isTextMessage:(NSDictionary *)ext{
    
    if (![KFSmartUtils canObjectForKey:ext]) {
        return NO;
    }
    
    NSDictionary *msgtype = [ext valueForKey:@"msgtype"];
    
    if ([KFSmartUtils canObjectForKey:msgtype]) {
        if ([KFSmartUtils canObjectForKey:[msgtype valueForKey:@"choice"]]) {
            return YES;
        }
    }
    return NO;
    
}



+ (BOOL)isImageMessage:(NSDictionary *)ext{
    
    if (![KFSmartUtils canObjectForKey:ext]) {
        return NO;
    }
    
    NSDictionary *msgtype = [ext valueForKey:@"msgtype"];
    
    if ([KFSmartUtils canObjectForKey:msgtype]) {
        if ([KFSmartUtils canObjectForKey:[msgtype valueForKey:@"choice"]]) {
            return YES;
        }
    }
    return NO;
    
}
+ (BOOL)isArticleMessage:(NSDictionary *)ext{
    
    if (![KFSmartUtils canObjectForKey:ext]) {
        return NO;
    }
    
    NSDictionary *msgtype = [ext valueForKey:@"msgtype"];
    
    if ([KFSmartUtils canObjectForKey:msgtype]) {
        if ([KFSmartUtils canObjectForKey:[msgtype valueForKey:@"articles"]]) {
            return YES;
        }
    }
    return NO;
    
}
+ (BOOL)canObjectForKey:(id)obj
{
    if (obj && obj != [NSNull null]) {
        return  YES;
    }
    return NO;
}

@end
