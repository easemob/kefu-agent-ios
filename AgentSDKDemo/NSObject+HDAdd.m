//
//  NSObject+HDAdd.m
//  AgentSDKDemo
//
//  Created by afanda on 4/14/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "NSObject+HDAdd.h"
#import <AVFoundation/AVFoundation.h>

@implementation NSObject (HDAdd)

- (BOOL)isSupportRecord {
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    
    return bCanRecord;
}

@end
