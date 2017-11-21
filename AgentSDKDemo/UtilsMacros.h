//
//  UtilsMacros.h
//  AgentSDKDemo
//
//  Created by afanda on 10/9/17.
//  Copyright © 2017 环信. All rights reserved.
//

#ifndef UtilsMacros_h
#define UtilsMacros_h


#define kAlert(msg) [[[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];

#define kWindow [UIApplication sharedApplication].keyWindow

#define kShowLoginViewControllerTag 1293
#define kTransferScheduleRequestTag 2934

#endif /* UtilsMacros_h */
