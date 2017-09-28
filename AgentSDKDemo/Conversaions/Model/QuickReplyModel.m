//
//  QuickReplyModel.m
//  EMCSApp
//
//  Created by EaseMob on 15/4/17.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "QuickReplyModel.h"

//#import "NSDictionary+SafeValue.h"

@implementation QuickReplyModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.agentUserId = [dictionary safeStringValueForKey:QUICKREPLY_AGENTUSERID];
        self.groupType = [dictionary safeStringValueForKey:QUICKREPLY_GROUPTYPE];
        self.shortcutMessageGroupId = [dictionary safeStringValueForKey:QUICKREPLY_SHOWCUTMESSAGEGROUPID];
        self.shortcutMessageGroupName = [dictionary safeStringValueForKey:QUICKREPLY_SHORTCUTMESSAGEGROUPNAME];
        self.tenantId = [dictionary safeStringValueForKey:QUICKREPLY_TENANTID];
    }
    
    return self;
}

@end

@implementation QuickReplyMessageModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.agentUserId = [dictionary safeStringValueForKey:@"agentUserId"];
        self.Id = [dictionary safeStringValueForKey:@"id"];
        self.phrase = [dictionary safeStringValueForKey:@"phrase"];
        self.tenantId = [dictionary safeStringValueForKey:@"tenantId"];
        self.seq = [dictionary safeIntegerValueForKey:@"seq"];
        self.parentId = [dictionary safeIntegerValueForKey:@"parentId"];
        self.leaf = [dictionary safeIntegerValueForKey:@"leaf"];
        self.deleted = [dictionary safeIntegerValueForKey:@"deleted"];
        self.children = [dictionary objectForKey:@"children"];
        self.brief = [dictionary objectForKey:@"brief"];
        if ([dictionary objectForKey:QUICKREPLYMESSAGE_CREATEDATETIME]) {
            self.createDateTime = [[dictionary safeStringValueForKey:QUICKREPLYMESSAGE_CREATEDATETIME] doubleValue];
        }
        if ([dictionary objectForKey:QUICKREPLYMESSAGE_LASTUPDATEDATETIME]) {
            self.lastUpdateDateTime = [[dictionary safeStringValueForKey:QUICKREPLYMESSAGE_LASTUPDATEDATETIME] doubleValue];
        }
    }
    
    return self;
}

- (NSDictionary *)getModelDictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.agentUserId.length > 0) {
        [dic setObject:self.agentUserId forKey:@"agentUserId"];
    }
    
    if (self.Id.length > 0) {
        [dic setObject:self.Id forKey:@"id"];
    }
    
    if (self.phrase.length > 0) {
        [dic setObject:self.phrase forKey:@"phrase"];
    }
    
    if (self.tenantId.length > 0) {
        [dic setObject:self.tenantId forKey:@"tenantId"];
    }
    
    [dic setObject:@(self.seq) forKey:@"seq"];
    [dic setObject:@(self.parentId) forKey:@"parentId"];
    [dic setObject:@(self.leaf) forKey:@"leaf"];
    [dic setObject:@(self.deleted) forKey:@"deleted"];
    
    [dic setObject:self.children forKey:@"children"];
    [dic setObject:self.brief forKey:@"brief"];
    
    if (self.createDateTime) {
        [dic setObject:@(self.createDateTime) forKey:QUICKREPLYMESSAGE_CREATEDATETIME];
    }
    if (self.lastUpdateDateTime) {
        [dic setObject:@(self.lastUpdateDateTime) forKey:QUICKREPLYMESSAGE_LASTUPDATEDATETIME];
    }
    return dic;
}
@end
