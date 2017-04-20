//
//  UIAlertView+AlertBlock.m
//  EMCSApp
//
//  Created by EaseMob on 15/5/7.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "UIAlertView+AlertBlock.h"
#import <objc/runtime.h>

@implementation UIAlertView (AlertBlock)

static char key;
- (void)showAlertViewWithCompleteBlock:(CompleteBlock)block
{
    if (block) {
        objc_removeAssociatedObjects(self);
        objc_setAssociatedObject(self, &key, block, OBJC_ASSOCIATION_COPY);
        self.delegate = self;
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    CompleteBlock block = objc_getAssociatedObject(self, &key);
    if (block) {
        block(buttonIndex);
    }
}

@end
