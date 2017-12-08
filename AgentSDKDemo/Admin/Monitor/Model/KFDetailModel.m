//
//  KFDetailModel.m
//  AgentSDKDemo
//
//  Created by afanda on 12/7/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "KFDetailModel.h"

@implementation KFDetailModel


- (NSString *)first_login_time_of_today {
    if (_first_login_time_of_today.length == 0) {
        return @"---";
    }
    return _first_login_time_of_today;
}


- (HDAgentLoginStatus)kfState {
    HDAgentLoginStatus state = 0;
    if ([_state isEqualToString:USER_STATE_ONLINE]) {
        state = HDAgentLoginStatusOnline;
    } else if ([_state isEqualToString:USER_STATE_BUSY]) {
        state = HDAgentLoginStatusBusy;
    } else if ([_state isEqualToString:USER_STATE_LEAVE]) {
        state = HDAgentLoginStatusLeave;
    } else if([_state isEqualToString:USER_STATE_HIDDEN]) {
        state = HDAgentLoginStatusHidden;
    } else if([_state isEqualToString:USER_STATE_OFFLINE]) {
        state = HDAgentLoginStatusOffline;
    }
    return state;
}

@end
