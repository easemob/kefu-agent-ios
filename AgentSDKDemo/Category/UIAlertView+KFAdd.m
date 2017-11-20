//
//  UIAlertView+KFAdd.m
//  AgentSDKDemo
//
//  Created by afanda on 11/16/17.
//  Copyright © 2017 环信. All rights reserved.
//
#import <objc/runtime.h>
#import "UIAlertView+KFAdd.h"

static const void *attKey = &attKey;

@implementation UIAlertView (KFAdd)

- (void)setSessionId:(NSString *)sessionId {
    objc_setAssociatedObject(self, attKey, sessionId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)sessionId {
    return objc_getAssociatedObject(self, attKey);
}

@end
