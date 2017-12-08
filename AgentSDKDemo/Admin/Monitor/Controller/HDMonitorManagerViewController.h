//
//  HDMonitorManagerViewController.h
//  AgentSDKDemo
//
//  Created by afanda on 12/4/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDMonitorCell.h"
#import "KFMonitorBaseViewController.h"
#define kGetAgentGroup @"/v1/monitor/agentqueues"
@interface HDMonitorManagerViewController : KFMonitorBaseViewController
@property(nonatomic,strong) KFArrowButtonView *head;
@end
