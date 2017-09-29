//
//  EMNotifyModel.h
//  EMCSApp
//
//  Created by EaseMob on 16/3/14.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

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

typedef NS_ENUM(NSUInteger, HDNoticeStatus) {
    HDNoticeStatusRead=66,    //已读
    HDNoticeStatusUnread,     //未读
};

typedef NS_ENUM(NSUInteger, HDNoticeType) {
    HDNoticeTypeAll = 88,          //所有消息
    HDNoticeTypeAgent,     //管理员消息
    HDNoticeTypeSystem       //系统消息
    
};

@interface HDNotifyModel : NSObject

@property (nonatomic, copy) NSString *activityId;
//actor
@property (nonatomic, copy) NSString *actorId;
@property (nonatomic, copy) NSString *objectType;
@property(nonatomic,copy) NSString *name;

@property (nonatomic, assign) NSTimeInterval createDateTime;
@property (nonatomic, copy) NSString *feedId;
//object
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSArray  *redirectInfo;
@property (nonatomic, copy) NSString *objectId;

@property (nonatomic, assign) HDNoticeStatus status;
@property (nonatomic, copy) NSString *tenantId;
@property(nonatomic,assign) HDNoticeType type;
@property (nonatomic, copy) NSString *verb;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
