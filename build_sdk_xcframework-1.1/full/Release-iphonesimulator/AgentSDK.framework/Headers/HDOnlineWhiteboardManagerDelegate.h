//
//  HDWhiteboardManagerDelegate.h
//  helpdesk_sdk
//
//  Created by houli on 2022/4/19.
//  Copyright © 2022 hyphenate. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HDOnlineWhiteboardManagerDelegate <NSObject>

@optional

- (void)onRoomDataReceivedParameter:(NSDictionary *)roomData;

@end

NS_ASSUME_NONNULL_END
