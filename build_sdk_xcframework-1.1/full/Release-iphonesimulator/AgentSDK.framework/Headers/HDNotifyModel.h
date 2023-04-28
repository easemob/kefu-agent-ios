//
//  EMNotifyModel.h
//  EMCSApp
//
//  Created by EaseMob on 16/3/14.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgentSDKTypes.h"

#define EM_NOTIFY_ID @"activity_id"
#define EM_NOTIFY_ACTOR @"actor"
#define EM_NOTIFY_ACTOR_ID @"id"
#define EM_NOTIFY_ACTOR_TYPE @"objectType"
#define EM_NOTIFY_CREATE_AT @"created_at"
#define EM_NOTIFY_FEED_ID @"feed_id"
#define EM_NOTIFY_OBJECT @"object"
#define EM_NOTIFY_OBJECT_CONTENT @"content"
#define EM_NOTIFY_OBJECT_CONTENT_DETAIL @"detail"
#define EM_NOTIFY_OBJECT_CONTENT_SUMMARY @"summary"
#define EM_NOTIFY_OBJECT_ID @"id"
#define EM_NOTIFY_STATUS @"status"
#define EM_NOTIFY_TENANT_ID @"tenant_id"
#define EM_NOTIFY_VERB @"verb"

@interface HDNotifyModel : NSObject

@property (nonatomic, copy) NSString *activityId;
//actor
@property (nonatomic, copy) NSString *actorId;
@property (nonatomic, copy) NSString *objectType;
@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) NSTimeInterval createDateTime;
@property (nonatomic, copy) NSString *feedId;
//object
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSArray  *redirectInfo;
@property (nonatomic, copy) NSString *objectId;

@property (nonatomic, assign) HDNoticeStatus status;
@property (nonatomic, copy) NSString *tenantId;
@property (nonatomic, assign) HDNoticeType type;
@property (nonatomic, copy) NSString *verb;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
