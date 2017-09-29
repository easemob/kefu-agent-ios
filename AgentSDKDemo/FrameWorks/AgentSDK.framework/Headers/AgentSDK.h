//
//  AgentSDK.h
//  AgentSDK
//
//  Created by afanda on 4/5/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for AgentSDK.
FOUNDATION_EXPORT double AgentSDKVersionNumber;

//! Project version string for AgentSDK.
FOUNDATION_EXPORT const unsigned char AgentSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <AgentSDK/PublicHeader.h>

#import <AgentSDK/HDConversation.h>
#import <AgentSDK/HDMessage.h>
#import <AgentSDK/HDWaitUser.h>
#import <AgentSDK/HDMessageBody.h>
#import <AgentSDK/HDError.h>
#import <AgentSDK/HDErrorCode.h>
#import <AgentSDK/HDClient.h>
#import <AgentSDK/HDChatManager.h>
#import <AgentSDK/HDNotifyModel.h>
#import <AgentSDK/HDClientDelegate.h>
#import <AgentSDK/HDChatManagerDelegate.h>
#import <AgentSDK/NSDictionary+SafeValue.h>
#import <AgentSDK/HDHistoryConversation.h>

//new
#import <AgentSDK/HDBaseMessageBody.h>
#import <AgentSDK/HDTextMessageBody.h>
#import <AgentSDK/HDImageMessageBody.h>
#import <AgentSDK/HDVoiceMessageBody.h>
#import <AgentSDK/HDFileMessageBody.h>
