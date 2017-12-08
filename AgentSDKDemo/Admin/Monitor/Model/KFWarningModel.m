//
//  KFWarningModel.m
//  AgentSDKDemo
//
//  Created by afanda on 12/8/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "KFWarningModel.h"

@implementation KFWarningModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"warningId":@[@"id"]
             };
}


@end
