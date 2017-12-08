//
//  KFMonitorDetailViewController.h
//  AgentSDKDemo
//
//  Created by afanda on 12/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFArrowButtonView.h"
#import "KFMonitorBaseViewController.h"

#define kMonitorDetail @"/v1/monitor/agentusers?queueId=%@"
@interface KFMonitorDetailViewController : KFMonitorBaseViewController
@property(nonatomic,strong) KFArrowButtonView *head;
@property(nonatomic,copy) NSString *groupName;
@property(nonatomic,copy) NSString *queueId;
@end
