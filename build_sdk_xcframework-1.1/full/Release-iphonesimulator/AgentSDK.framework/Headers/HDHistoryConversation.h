//
//  HDHistoryConversation.h
//  AgentSDK
//
//  Created by afanda on 9/5/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <AgentSDK/AgentSDK.h>

@interface HDHistoryConversation : HDConversation
@property (nonatomic, copy) NSString *agentUserNiceName;
@property (nonatomic, copy) NSArray *summarys;
@end
