//
//  HLeaveMessageRetrievalViewController.h
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/6/26.
//  Copyright © 2018年 环信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AgentSDK/AgentSDK.h>
@protocol HLeaveMessageRetrievalDelegate
- (void)didSelectLeaveMessageRetrieval:(HLeaveMessageRetrieval *)aRetrieval;
@end

@interface HLeaveMessageRetrievalViewController : UITableViewController
@property (nonatomic, strong) HLeaveMessageRetrieval *retrieval;
@property (nonatomic, assign) id <HLeaveMessageRetrievalDelegate> delegate;
@end
