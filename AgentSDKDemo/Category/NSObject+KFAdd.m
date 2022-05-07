//
//  NSObject+KFAdd.m
//  EMCSApp
//
//  Created by afanda on 16/11/2.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "NSObject+KFAdd.h"
#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>

@implementation NSObject (KFAdd)

- (NSMutableDictionary *)dicFromModel {
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        id value = [self valueForKey:key];
        if (key && value) {
            if ([value isKindOfClass:[NSString class]]
                || [value isKindOfClass:[NSNumber class]]) {
                // 普通类型的直接变成字典的值
                [dict setObject:value forKey:key];
            }
        } else if (key && value == nil) {
            // 如果当前对象该值为空，设为nil。在字典中直接加nil会抛异常，需要加NSNull对象
            [dict setObject:[NSNull null] forKey:key];
        }
    }
    free(properties);
    return dict;
}

- (BOOL)isPermission {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
            return NO;
            break;
        default:
            break;
    }
    return YES;
}

- (BOOL)isSupportRecord {
    __block BOOL bCanRecord = YES;
#if !TARGET_IPHONE_SIMULATOR
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            
            bCanRecord = granted;
        }];
    }
#endif
    return bCanRecord;
}

@end
