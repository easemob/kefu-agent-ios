//
//  HDAgoraCallManagerDelegate.h
//  CustomerSystem-ios
//
//  Created by houli on 2022/3/4.
//  Copyright © 2022 easemob. All rights reserved.
//
#import "HDVECAgoraCallMember.h"
@protocol HDVECAgoraCallManagerDelegate <NSObject>

@optional

/*!
 *  \~chinese
 *  成员进入会话
 *  @param member  成员
 *
 *  \~english
 *  Member enters session
 *
 */
- (void)onMemberJoin:(HDVECAgoraCallMember *)member;

/*!
 *  \~chinese
 *  成员离开会话
 *  @param member  成员
 *
 *  \~english
 *  Member exit session
 *
 */
- (void)onMemberExit:(HDVECAgoraCallMember *)member;

/*!
 *  \~chinese
 *  会话结束
 *  @param reason 原因
 *  @param desc 描述
 *
 *  \~english
 *  End of the session
 *
 */
- (void)onCallEndReason:(int)reason desc:(NSString *)desc withRecordData:(id)result;

/*!
 *  \~chinese
 *    远端用户音频静音通知
 *  @param desc 描述
 *
 *  \~english
 *  End of the session
 *
 */
- (void)onCalldidAudioMuted:(BOOL)muted byUid:(NSUInteger)uid;
/*!
 *  \~chinese
 *    远端用户视频关闭通知
 *  @param desc 描述
 *
 *  \~english
 *  End of the session
 *
 */
- (void)onCalldidVideoMuted:(BOOL)muted byUid:(NSUInteger)uid;
@end
