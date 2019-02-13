//
//  HDSuperviseManagerViewController.h
//  AgentSDKDemo
//
//  Created by afanda on 12/4/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDSuperviseCell.h"
#import "KFSuperviseBaseViewController.h"
#define kGetAgentGroup @"/v1/monitor/agentqueues"
@interface HDSuperviseManagerViewController : KFSuperviseBaseViewController
@property (nonatomic, strong) KFArrowButtonView *head;
@end
