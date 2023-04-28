//
//  HDAppManager.m
//  AgentSDKDemo
//
//  Created by easemob on 2023/2/10.
//  Copyright © 2023 环信. All rights reserved.
//

#import "HDAppManager.h"

@implementation HDAppManager
static HDAppManager *shareCall = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareCall = [[HDAppManager alloc] init];
       
    });
    return shareCall;
}

@end
