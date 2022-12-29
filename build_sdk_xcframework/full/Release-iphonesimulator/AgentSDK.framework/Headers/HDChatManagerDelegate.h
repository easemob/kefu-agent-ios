//
//  HDChatManagerDelegate.h
//  AgentSDK
//
//  Created by afanda on 4/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDMessage.h"
#import "HDError.h"

@protocol HDChatManagerDelegate <NSObject>
/*
 *  收到新消息
 *
 *  @param aMessages  消息列表<MessageModel>
 */
- (void)messagesDidReceive:(NSArray <HDMessage *> *)aMessages;

/*
 *  收到cmd新消息 智能辅助
 *
 *  @param aMessages  消息列表<MessageModel>
 */
- (void)messagesCmdCooperationAnswerDidReceive:(NSArray <HDMessage *> *)aMessages;

/*
 *  坐席主动发送视频邀请收到的通知
 *
 *  @param aMessage  消息<MessageModel>
 */
- (void)messagesLiveStreamInvitationDidReceive:(HDMessage *)aMessage;

/*
 *  消息状态发生变化
 *
 *  @param aMessage  状态发生变化的消息
 *  @param aError    出错信息
 */
- (void)messageStatusDidChange:(HDMessage *)aMessage
                         error:(HDError *)aError;

/*
 *  消息附件状态发生改变
 *
 *  @param aMessage  附件状态发生变化的消息
 *  @param aError    错误信息
 */
- (void)messageAttachmentStatusDidChange:(HDMessage *)aMessage
                                   error:(HDError *)aError;


/**
 visitor input state change

 @param content text
 */
- (void)visitorInputStateChange:(NSString *)content;

@end
