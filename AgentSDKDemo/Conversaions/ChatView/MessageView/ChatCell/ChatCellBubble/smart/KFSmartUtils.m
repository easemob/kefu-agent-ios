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
+ (BOOL)isHtmlMessage:(HDMessage *)message {
  
    if (message.nBody.type == HDMessageBodyTypeText) {
        
        HDTextMessageBody *  body = (HDTextMessageBody *)message.nBody;
        
        NSLog(@"======HDTextMessageBody = %@",body.text);
        if (![KFSmartUtils isJsonString:body.text]) {
            
            return NO;
        }
        NSDictionary * msg = [HDUtils dictionaryWithString:body.text];
        if ([[msg allKeys] containsObject:@"content"]) {
            NSString * content = [msg objectForKey:@"content"];
            
            if (content && content.length > 0) {
                
                return YES;
            }
            
        }
    
    }
   
    return NO;
}
+ (BOOL)isJsonString:(NSString *)jsonString{
    if (jsonString.length < 2) return NO;
    if (!([jsonString hasPrefix:@"{"] || [jsonString hasPrefix:@"["])) return NO;
    // {:123  }:125  [: 91  ]:93
    return [jsonString characterAtIndex:jsonString.length-1]-[jsonString characterAtIndex:0] == 2;
}

+ (id)jsonToObj:(NSString *)jsonString{
    if (![self isJsonString:jsonString]) return nil;
    NSError *err;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id obj;
    if (jsonData) {
        obj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    }
    if (err) {
        return nil;
    }
    return obj;
}


+ (NSDictionary *)dictionaryWithString:(NSString *)string {
    if (string && 0 != string.length) {
        NSError *error = nil;
        NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            [HDLog logE:@"string:%@ 解析为json失败 !error: %@",string,error];
            return nil;
        }
        return jsonDict;
    }
    return nil;
}


@end
