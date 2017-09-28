//
//  HDSetManager.h
//  AgentSDK
//
//  Created by afanda on 9/20/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDUserTag.h"

typedef NS_ENUM(NSUInteger, HDOnlineStatus) {
    HDOnlineStatusOnline = 0,   //在线
    HDOnlineStatusBusy,     //忙碌
    HDOnlineStatusLeave,    //离开
    HDOnlineStatusHidden    //隐身
};

@interface HDSetManager : NSObject




/**
 更新问候语

 @param content 问候语
 @param completion 完成回调
 */
- (void)updateGreetingContent:(NSString *)content completion:(void(^)(id responseObject,HDError *error))completion;


/**
 修改个人信息

 @param key key
 @param value 值
 @param completion 完成回调
 */
- (void)modifyInfoWithKey:(NSString *)key value:(NSString *)value completion:(void(^)(id responseObject,HDError *error))completion;


/**
 开启、关闭问候语

 @param enable YES为开启、NO为关闭
 */
- (void)enableGreeting:(BOOL)enable completion:(void(^)(id responseObject,HDError *error))completion;



/**
 上传头像

 @param imageData 图片data
 @param completion 完成回调
 */
- (void)asyncUploadImageWithFile:(NSData*)imageData
                       completion:(void (^)(NSString *url, HDError *error))completion;



/**
 访客标签

 @param userId userId
 @param completion 完成回调
 */
- (void)getVisitorUserTagsWithUserId:(NSString *)userId completion:(void(^)(id responseObject,HDError *error))completion;


/**
 修改访客标签

 @param userTag 访客id
 @param completion 完成回调
 */
- (void)updateVisitorUserTagWithUserTag:(HDUserTag *)userTag completion:(void(^)(id responseObject,HDError *error))completion;


/**
 修改最大接入数

 @param userNum 人数
 @param completion 完成回调
 */
- (void)updateServiceUsersWithNum:(NSString *)userNum completion:(void(^)(id responseObject,HDError *error))completion;


/**
 更新在线状态

 @param status 状态
 @param completion 完成回调
 */
- (void)updateOnLineStatusWithStatus:(HDOnlineStatus)status
                          completion:(void (^)(id responseObject, HDError *error))completion;



@end



