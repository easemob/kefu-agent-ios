//
//  DXMessageManager.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/20.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HyphenateLite/HyphenateLite.h>


// 连接状态
typedef enum DXMessageManagerState
{
    DX_DISCONNECTED,
    DX_CONNECTED,
} DXMessageManagerState;

@interface DXMessageManager : NSObject <EMChatManagerDelegate>

+ (instancetype)shareManager;

- (BOOL)currentState;

- (void)setCurSessionId:(NSString*)curSessionId;

- (NSString*)curSessionId;

- (void)registerEaseMobNotification;

@end
