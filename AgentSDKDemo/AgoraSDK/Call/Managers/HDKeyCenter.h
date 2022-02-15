//
//  HDAppID.h
//  HelpDeskLite
//
//  Created by houli on 2022/1/6.
//  Copyright © 2022 hyphenate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDKeyCenter : NSObject
/**
  声网 appid 访客端通过消息传过来
 */
@property (nonatomic, strong)  NSString * agoraAppid;

/**
 声网token 访客端通过消息传过来
 */
@property (nonatomic, strong) NSString * agoraToken;
/**
 声网channel 访客端通过消息传过来
 */
@property (nonatomic, strong) NSString * agoraChannel;
/**
 声网uid 访客端通过消息传过来
 */
@property (nonatomic, strong) NSString * agoraUid;
/**
 callid 访客端通过消息传过来
 */
@property (nonatomic, strong) NSString * callid;
/**
 屏幕分享id
 */
@property (nonatomic, strong) NSString * shareUid;

@end


