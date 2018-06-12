//
//  HDMessage+Category.m
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/5/29.
//  Copyright © 2018年 环信. All rights reserved.
//

#import "HDMessage+Category.h"

@implementation HDMessage (Category)
- (BOOL)isRecall {
    BOOL ret = NO;
    id ext = [self.nBody.msgExt objectForKey:@"weichat"];
    if (ext != [NSNull null]) {
        if ([[self.nBody.msgExt objectForKey:@"weichat"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *weichat = [self.nBody.msgExt objectForKey:@"weichat"];
            if (weichat) {
                if ([[weichat objectForKey:@"recall_flag"] isKindOfClass:[NSNumber class]]) {
                    ret = [[weichat objectForKey:@"recall_flag"] boolValue];
                }
            }
        }
    }
    
    return ret;
}

@end
