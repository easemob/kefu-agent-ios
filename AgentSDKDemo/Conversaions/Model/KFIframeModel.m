//
//  KFIframeModel.m
//  AgentSDK
//
//  Created by 杜洁鹏 on 2019/2/13.
//  Copyright © 2019 环信. All rights reserved.
//

#import "KFIframeModel.h"

@implementation KFIframeModel
+(BOOL)propertyIsOptional:(NSString *)propertyName
{
    return true;
}
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"id": @"iFrameId"
    }];
}
@end
