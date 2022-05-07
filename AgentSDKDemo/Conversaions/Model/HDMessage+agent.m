//
//  HDMessage+agent.m
//  AgentSDKDemo
//
//  Created by afanda on 11/14/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <objc/runtime.h>
#import "HDMessage+agent.h"

static const void *attKey = &attKey;

@implementation HDMessage (agent)

- (void)setAtt:(NSAttributedString *)att {
    objc_setAssociatedObject(self, attKey, att, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSAttributedString *)att {
    return objc_getAssociatedObject(self, attKey);
}

@end
