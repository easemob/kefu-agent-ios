//
//  NSArray+KFCrashArray_h.m
//  AgentSDKDemo
//
//  Created by easemob on 2023/3/29.
//  Copyright © 2023 环信. All rights reserved.
//

#import "NSArray+KFCrashArray.h"
#import <objc/runtime.h>
@implementation NSObject (Until)
 
- (void)swizzleMethod:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector{
    Class class = [self class];
    Method original = class_getInstanceMethod(class, originalSelector);
    Method Swizzl   = class_getInstanceMethod(class, swizzledSelector);
 
    BOOL didAdd = class_addMethod(class, originalSelector, method_getImplementation(Swizzl), method_getTypeEncoding(Swizzl));
    if (didAdd) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(original), method_getTypeEncoding(original));
    }else{
        method_exchangeImplementations(original, Swizzl);
    }
}
 
@end
@implementation NSArray (KFCrashArray)
- (id)safeObjectAtIndex:(NSUInteger)index{
    if (index<self.count) {
        return [self safeObjectAtIndex:index];
    }else{
//#ifdef DEBUG
//        NSAssert(NO, @"index %lu > count %lu",(unsigned long)index,(unsigned long)self.count);
//#endif
        return nil;
    }
}
- (id)safeObjectAtIndex1:(NSUInteger)index{
    if (index<self.count) {
        return [self safeObjectAtIndex1:index];
    }else{
//#ifdef DEBUG
//        NSAssert(NO, @"index %lu > count %lu",(unsigned long)index,(unsigned long)self.count);
//#endif
        return nil;
    }
}
- (id)safeObjectAtIndex2:(NSUInteger)index{
    if (index<self.count) {
        return [self safeObjectAtIndex2:index];
    }else{
//#ifdef DEBUG
//        NSAssert(NO, @"index %lu > count %lu",(unsigned long)index,(unsigned long)self.count);
//#endif
        return nil;
    }
}
- (id)safeObjectAtIndex3:(NSUInteger)index{
    if (index<self.count) {
        return [self safeObjectAtIndex3:index];
    }else{
//#ifdef DEBUG
//        NSAssert(NO, @"index %lu > count %lu",(unsigned long)index,(unsigned long)self.count);
//#endif
        return nil;
    }
}
 
+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            [objc_getClass("__NSArrayI") swizzleMethod:@selector(objectAtIndex:) swizzledSelector:@selector(safeObjectAtIndex:)];
            [objc_getClass("__NSArrayI") swizzleMethod:@selector(objectAtIndexedSubscript:) swizzledSelector:@selector(safeObjectAtIndex1:)];
 
            [objc_getClass("__NSArrayM") swizzleMethod:@selector(objectAtIndex:) swizzledSelector:@selector(safeObjectAtIndex2:)];
            [objc_getClass("__NSArrayM") swizzleMethod:@selector(objectAtIndexedSubscript:) swizzledSelector:@selector(safeObjectAtIndex3:)];
        }
    });
}
@end
@implementation NSDictionary(DictinaryCrash)
 
- (void)mutableSetObject:(id)obj forKey:(NSString *)key{
    if (obj && key) {
        [self mutableSetObject:obj forKey:key];
    }
}
+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool{
            [objc_getClass("__NSDictionaryM") swizzleMethod:@selector(setObject:forKey:) swizzledSelector:@selector(mutableSetObject:forKey:)];
        }
    });
}
@end
